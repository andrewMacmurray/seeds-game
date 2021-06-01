module Scene.Level exposing
    ( Model
    , Msg
    , Status(..)
    , getContext
    , init
    , menuOptions
    , update
    , updateContext
    , view
    )

import Board exposing (Board)
import Board.Block as Block exposing (Block)
import Board.Coord exposing (Coord)
import Board.Falling exposing (..)
import Board.Generate as Generate
import Board.Mechanic.Burst as Burst
import Board.Mechanic.Pod as Pod
import Board.Move as Move exposing (Move)
import Board.Move.Move as Move
import Board.Scores as Scores exposing (Scores)
import Board.Shift as Board
import Board.Tile as Tile exposing (State(..), Tile(..))
import Board.Wall as Wall
import Config.Level as Level
import Context exposing (Context)
import Dict exposing (Dict)
import Element exposing (..)
import Element.Button.Cancel as Cancel
import Element.Info as Info
import Element.Layout as Layout
import Element.Text as Text
import Element.Touch as Touch
import Exit exposing (continue, exitWith)
import Html exposing (Attribute, Html)
import Level.Setting.Start as Start
import Level.Setting.Tile as Tile
import Lives
import Scene.Level.Board.Line as Line
import Scene.Level.Board.LineDrag as LineDrag
import Scene.Level.Board.Style as Board
import Scene.Level.Board.Tile2 as Tile
import Scene.Level.TopBar as TopBar
import Scene.Level.Tutorial as Tutorial
import Seed
import Utils.Delay as Delay
import Utils.Dict exposing (indexedDictFrom)
import Utils.Element as Element
import Utils.Update exposing (andThenWithCmds)
import View.Menu as Menu



-- Model


type alias Model =
    { context : Context
    , tutorial : Tutorial.Tutorial
    , board : Board
    , scores : Scores
    , isDragging : Bool
    , remainingMoves : Int
    , tileSettings : List Tile.Setting
    , boardSize : Board.Size
    , levelStatus : Status
    , info : Info.State LevelEndPrompt
    , pointer : Touch.Point
    }


type Msg
    = BoardGenerated Level.LevelConfig Board
    | StartTutorial
    | NextTutorialStep
    | HideTutorialStep
    | StopMove
    | StartMove Move Touch.Point
    | CheckMove Touch.Point
    | ReleaseTile
    | SetLeavingTiles
    | SetFallingTiles
    | SetGrowingSeedPods
    | GrowPodsToSeeds (Maybe Seed.Seed)
    | AddGrowingSeeds (List Tile)
    | ResetGrowingSeeds
    | BurstTiles
    | GenerateEnteringTiles Generate.Setting
    | InsertEnteringTiles (List Tile)
    | ResetEntering
    | ShiftBoard
    | EndMove
    | CheckLevelComplete
    | ShowInfo LevelEndPrompt
    | HideInfo
    | InfoLeaving
    | InfoHidden
    | PromptRestart
    | PromptExit
    | LevelWon
    | LevelLost
    | RestartLevel
    | RestartLevelLoseLife
    | ExitLevel
    | ExitLevelLoseLife


type Status
    = NotStarted
    | InProgress
    | Lose
    | Win
    | Restart
    | Exit


type LevelEndPrompt
    = Success
    | NoMovesLeft
    | RestartAreYouSure
    | ExitAreYouSure



-- Context


getContext : Model -> Context
getContext model =
    model.context


updateContext : (Context -> Context) -> Model -> Model
updateContext f model =
    { model | context = f model.context }



-- Menu


menuOptions : Model -> List (Menu.Option Msg)
menuOptions model =
    if canRestartLevel model then
        [ Menu.option PromptRestart "Restart"
        , Menu.option PromptExit "Exit"
        ]

    else
        [ Menu.option PromptExit "Exit"
        ]


canRestartLevel : Model -> Bool
canRestartLevel model =
    Lives.remaining model.context.lives > 1 || model.levelStatus == NotStarted



-- Init


init : Level.LevelConfig -> Context -> ( Model, Cmd Msg )
init config context =
    initialState config context
        |> andThenWithCmds
            [ generateBoard config
            , handleStartTutorial
            ]


initialState : Level.LevelConfig -> Context -> Model
initialState config context =
    { context = context
    , tutorial = config.tutorial
    , board = Board.empty
    , scores = Scores.init config.tileSettings
    , isDragging = False
    , remainingMoves = config.moves
    , tileSettings = config.tileSettings
    , boardSize = config.boardSize
    , levelStatus = NotStarted
    , info = Info.hidden
    , pointer = Touch.origin
    }


handleStartTutorial : Model -> Cmd Msg
handleStartTutorial _ =
    Delay.after 2800 StartTutorial



-- Update


update : Msg -> Model -> Exit.With Status ( Model, Cmd Msg )
update msg model =
    case msg of
        BoardGenerated config board ->
            continue (initBoard config board model) []

        StartTutorial ->
            continue { model | tutorial = Tutorial.showStep model.tutorial } []

        NextTutorialStep ->
            handleTutorialStep model

        HideTutorialStep ->
            continue { model | tutorial = Tutorial.hideStep model.tutorial } []

        StopMove ->
            continue model [ stopMoveSequence model.board ]

        ReleaseTile ->
            continue (releaseTiles model) []

        SetLeavingTiles ->
            continue (setLeavingTiles model) []

        SetFallingTiles ->
            continue (updateBoard setFallingTiles model) []

        ShiftBoard ->
            continue (shiftBoard model) []

        SetGrowingSeedPods ->
            continue (updateBoard Pod.growPods model) []

        GrowPodsToSeeds seedType ->
            continue model [ generateSeedType seedType model.board model.tileSettings ]

        AddGrowingSeeds seeds ->
            continue (updateBoard (Pod.growSeeds seeds model.tileSettings) model) []

        ResetGrowingSeeds ->
            continue (updateBoard Pod.reset model) []

        GenerateEnteringTiles generateSetting ->
            continue model [ generateEnteringTiles generateSetting model.board model.tileSettings ]

        BurstTiles ->
            continue (updateBoard Burst.burst model) []

        InsertEnteringTiles tiles ->
            continue (insertEnteringTiles tiles model) []

        ResetEntering ->
            continue (updateBlocks Block.setEnteringToStatic model) []

        EndMove ->
            continue (endMove model) []

        StartMove move pointer ->
            continue (handleStartMove move pointer model) []

        CheckMove pointer ->
            continue (checkMoveFromPosition pointer model) []

        CheckLevelComplete ->
            checkLevelComplete model

        HideInfo ->
            continue model [ hideInfoSequence ]

        ShowInfo info ->
            continue { model | info = Info.visible info } []

        InfoLeaving ->
            continue { model | info = Info.leaving model.info } []

        InfoHidden ->
            continue { model | info = Info.hidden } []

        PromptRestart ->
            continue (updateContext Context.closeMenu model) [ handleRestartPrompt model ]

        PromptExit ->
            continue (updateContext Context.closeMenu model) [ handleExitPrompt model ]

        LevelWon ->
            exitWith Win model

        LevelLost ->
            exitWith Lose model

        RestartLevel ->
            exitWith Restart model

        RestartLevelLoseLife ->
            exitWith Restart <| updateContext Context.decrementLife model

        ExitLevel ->
            exitWith Exit model

        ExitLevelLoseLife ->
            exitWith Exit <| updateContext Context.decrementLife model



-- Sequences


stopMoveSequence : Board -> Cmd Msg
stopMoveSequence board =
    if shouldRelease board then
        triggerRelease

    else if Burst.shouldBurst board then
        burstSequence board

    else if Pod.shouldGrow board then
        growSeedPodsSequence board

    else
        removeTilesSequence Generate.All


burstSequence : Board -> Cmd Msg
burstSequence board =
    Board.activeMoveType board
        |> Maybe.map Generate.Filtered
        |> Maybe.withDefault Generate.All
        |> burstTilesSequence board


shouldRelease : Board -> Bool
shouldRelease board =
    List.length (Board.activeMoves board) == 1


growSeedPodsSequence : Board -> Cmd Msg
growSeedPodsSequence board =
    Delay.sequence
        [ ( 0, EndMove )
        , ( 0, SetGrowingSeedPods )
        , ( 800, GrowPodsToSeeds (Board.activeSeedType board) )
        , ( 0, CheckLevelComplete )
        , ( 600, ResetGrowingSeeds )
        , ( 500, NextTutorialStep )
        ]


removeTilesSequence : Generate.Setting -> Cmd Msg
removeTilesSequence enteringTiles =
    Delay.sequence
        [ ( 0, EndMove )
        , ( 0, SetLeavingTiles )
        , ( 350, SetFallingTiles )
        , ( 500, ShiftBoard )
        , ( 0, CheckLevelComplete )
        , ( 0, GenerateEnteringTiles enteringTiles )
        , ( 500, ResetEntering )
        , ( 500, NextTutorialStep )
        ]


burstTilesSequence : Board -> Generate.Setting -> Cmd Msg
burstTilesSequence board generateSetting =
    case Board.activeMoveType board of
        Just SeedPod ->
            Delay.sequence
                [ ( 0, EndMove )
                , ( 0, BurstTiles )
                , ( 700, SetGrowingSeedPods )
                , ( 800, GrowPodsToSeeds (Board.activeSeedType board) )
                , ( 0, CheckLevelComplete )
                , ( 600, ResetGrowingSeeds )
                , ( 500, NextTutorialStep )
                ]

        _ ->
            Delay.sequence
                [ ( 0, EndMove )
                , ( 0, BurstTiles )
                , ( 700, SetLeavingTiles )
                , ( 550, SetFallingTiles )
                , ( 500, ShiftBoard )
                , ( 0, CheckLevelComplete )
                , ( 0, GenerateEnteringTiles generateSetting )
                , ( 500, ResetEntering )
                , ( 500, NextTutorialStep )
                ]


winSequence : Cmd Msg
winSequence =
    Delay.sequence
        [ ( 500, ShowInfo Success )
        , ( 2000, HideInfo )
        , ( 1000, LevelWon )
        ]


loseSequence : Cmd Msg
loseSequence =
    Delay.sequence
        [ ( 500, ShowInfo NoMovesLeft )
        , ( 2000, HideInfo )
        , ( 1000, LevelLost )
        ]


hideInfoSequence : Cmd Msg
hideInfoSequence =
    Delay.sequence
        [ ( 0, InfoLeaving )
        , ( 1000, InfoHidden )
        ]



-- Update Board


type alias HasBoard model =
    { model | board : Board, boardSize : Board.Size }


updateBlocks : (Block -> Block) -> HasBoard model -> HasBoard model
updateBlocks f model =
    { model | board = Board.updateBlocks f model.board }


updateBoard : (Board -> Board) -> HasBoard model -> HasBoard model
updateBoard f model =
    { model | board = f model.board }



-- Init Board


generateBoard : Level.LevelConfig -> Model -> Cmd Msg
generateBoard config { boardSize } =
    Generate.board (BoardGenerated config) config.tileSettings boardSize


initBoard : Level.LevelConfig -> Board -> HasBoard model -> HasBoard model
initBoard config board model =
    model
        |> updateBoard (always board)
        |> updateBoard (addStartTiles config.startTiles)
        |> updateBoard (Wall.addToBoard config.walls)


addStartTiles : List Start.Tile -> Board -> Board
addStartTiles startTiles board =
    List.foldl (Board.place << Start.move) board startTiles



-- Entering Tiles


generateEnteringTiles : Generate.Setting -> Board -> List Tile.Setting -> Cmd Msg
generateEnteringTiles =
    Generate.enteringTiles InsertEnteringTiles


insertEnteringTiles : List Tile -> HasBoard model -> HasBoard model
insertEnteringTiles =
    updateBoard << Generate.insertEnteringTiles



-- End Move


endMove : Model -> Model
endMove =
    stopDrag >> decrementRemainingMoves



-- Release


triggerRelease : Cmd Msg
triggerRelease =
    Delay.trigger ReleaseTile


releaseTiles : Model -> Model
releaseTiles =
    stopDrag
        >> handleResetTutorial
        >> updateBlocks Block.setDraggingToStatic



-- Shift


shiftBoard : Model -> Model
shiftBoard =
    updateBoard Board.shift
        >> updateBlocks Block.setFallingToStatic
        >> updateBlocks Block.setLeavingToEmpty



-- Seed Pods


generateSeedType : Maybe Seed.Seed -> Board -> List Tile.Setting -> Cmd Msg
generateSeedType =
    Pod.generateNewSeeds AddGrowingSeeds


isSeedPodMove : Model -> Bool
isSeedPodMove model =
    model.board
        |> Board.activeMoves
        |> List.map Move.tile
        |> List.member (Just SeedPod)



-- Leaving


setLeavingTiles : Model -> Model
setLeavingTiles =
    addScores
        >> updateBlocks Block.setDraggingToLeaving
        >> updateBoard Burst.reset


addScores : Model -> Model
addScores model =
    { model | scores = Scores.addScoreFromMoves model.board model.scores }



-- Tutorial


handleResetTutorial : Model -> Model
handleResetTutorial model =
    if Tutorial.inProgress model.tutorial then
        { model | tutorial = Tutorial.showStep model.tutorial }

    else
        model


handleTutorialStep : Model -> Exit.With Status ( Model, Cmd Msg )
handleTutorialStep model =
    let
        nextTutorial =
            Tutorial.nextStep model.tutorial
    in
    continue { model | tutorial = nextTutorial } [ triggerHideAutoStep nextTutorial ]


triggerHideAutoStep : Tutorial.Tutorial -> Cmd Msg
triggerHideAutoStep next =
    if Tutorial.isAutoStep next then
        Delay.after 3000 HideTutorialStep

    else
        Cmd.none



-- Moves


stopDrag : Model -> Model
stopDrag model =
    { model | isDragging = False }


decrementRemainingMoves : Model -> Model
decrementRemainingMoves model =
    if model.remainingMoves < 1 then
        { model | remainingMoves = 0 }

    else
        { model | remainingMoves = model.remainingMoves - 1 }


handleStartMove : Move -> Touch.Point -> Model -> Model
handleStartMove move pointer model =
    { model
        | isDragging = True
        , board = Move.drag model.boardSize move model.board
        , pointer = pointer
        , tutorial = Tutorial.hideStep model.tutorial
    }


checkMoveFromPosition : Touch.Point -> Model -> Model
checkMoveFromPosition pointer model =
    case moveFromPosition pointer model of
        Just move ->
            handleCheckMove move { model | pointer = pointer }

        Nothing ->
            { model | pointer = pointer }


handleCheckMove : Move -> Model -> Model
handleCheckMove move model =
    if model.isDragging then
        updateBoard (Move.drag model.boardSize move) model

    else
        model



-- Move from position


moveFromPosition : Touch.Point -> Model -> Maybe Move
moveFromPosition pointer model =
    moveFromCoord model.board <| coordsFromPosition pointer model


moveFromCoord : Board -> Coord -> Maybe Move
moveFromCoord board coord =
    board
        |> Board.findBlockAt coord
        |> Maybe.map (Move.move coord)


coordsFromPosition : Touch.Point -> Model -> Coord
coordsFromPosition pointer model =
    let
        viewModel =
            boardViewModel model

        positionY =
            toFloat <| pointer.y - Board.offsetTop viewModel

        positionX =
            toFloat <| pointer.x - Board.offsetLeft viewModel

        scaleFactorY =
            Tile.scale model.context.window * Tile.baseSizeY

        scaleFactorX =
            Tile.scale model.context.window * Tile.baseSizeX
    in
    ( floor <| positionY / scaleFactorY
    , floor <| positionX / scaleFactorX
    )



-- Level End


checkLevelComplete : Model -> Exit.With Status ( Model, Cmd Msg )
checkLevelComplete model =
    let
        disableMenu =
            updateContext Context.disableMenu
    in
    if hasWon model then
        continue (disableMenu { model | levelStatus = Win }) [ winSequence ]

    else if hasLost model then
        continue (disableMenu { model | levelStatus = Lose }) [ loseSequence ]

    else
        continue { model | levelStatus = InProgress } []


hasLost : Model -> Bool
hasLost { remainingMoves, levelStatus } =
    remainingMoves < 1 && levelStatus == InProgress


hasWon : Model -> Bool
hasWon { scores, levelStatus } =
    Scores.allComplete scores && levelStatus == InProgress


handleExitPrompt : Model -> Cmd Msg
handleExitPrompt model =
    if model.levelStatus == NotStarted then
        Delay.trigger ExitLevel

    else
        Delay.trigger (ShowInfo ExitAreYouSure)


handleRestartPrompt : Model -> Cmd Msg
handleRestartPrompt model =
    if model.levelStatus == NotStarted then
        Delay.trigger RestartLevel

    else
        Delay.trigger (ShowInfo RestartAreYouSure)



-- View


view : Model -> Html Msg
view model =
    Layout.view
        [ handleStop model
        , handleCheck model
        , disableIfComplete model
        , behindContent (topBar model)
        , behindContent (currentMoveOverlay model)
        , behindContent (lineDrag model)
        , inFront (infoWindow model)
        , inFront (tutorialOverlay model)
        ]
        (renderBoard model)


topBar : Model -> Element msg
topBar =
    topBarViewModel >> TopBar.view >> html


handleStop : Model -> Element.Attribute Msg
handleStop model =
    Element.applyIf model.isDragging (Touch.onRelease StopMove)


handleCheck : Model -> Element.Attribute Msg
handleCheck model =
    Element.applyIf model.isDragging (Touch.onMove CheckMove)


disableIfComplete : Model -> Element.Attribute msg
disableIfComplete model =
    Element.applyIf (Scores.allComplete model.scores) Element.disableTouch


lineDrag : Model -> Element msg
lineDrag =
    lineDragViewModel >> LineDrag.view >> html



-- Tutorial Overlay


tutorialOverlay : Model -> Element msg
tutorialOverlay =
    tutorialViewModel >> Tutorial.view >> html


tutorialViewModel : Model -> Tutorial.ViewModel
tutorialViewModel model =
    { window = model.context.window
    , boardSize = model.boardSize
    , tileSettings = model.tileSettings
    , tutorial = model.tutorial
    }



-- Board


renderBoard : Model -> Element Msg
renderBoard model =
    el
        [ width (px (Board.width (boardViewModel model)))
        , moveDown (toFloat (Board.offsetTop (boardViewModel model)))
        , behindContent (renderLines model)
        , centerX
        ]
        (renderTiles model)


renderTiles : Model -> Element Msg
renderTiles model =
    toFloating (mapTiles (renderTile model) model.board)


toFloating : List (Element msg) -> Element msg
toFloating =
    List.foldl (\el attrs -> inFront el :: attrs) [] >> (\attrs -> el attrs none)


renderTile : Model -> Move -> Element Msg
renderTile model move =
    el
        [ handleMoveEvents model move
        , pointer
        , Element.noZoom
        ]
        (Tile.view
            { boardSize = model.boardSize
            , window = model.context.window
            , settings = model.tileSettings
            , isBursting = Burst.isBursting model.board
            , withTracer = True
            }
            move
        )


currentMoveOverlay : Model -> Element msg
currentMoveOverlay model =
    el
        [ Board.width2 (boardViewModel model)
        , Board.offsetTop2 (boardViewModel model)
        , centerX
        ]
        (currentMoveLayer model)


currentMoveLayer : Model -> Element msg
currentMoveLayer model =
    toFloating (mapTiles (renderCurrentMove model) model.board)


renderCurrentMove : Model -> Move -> Element msg
renderCurrentMove model move =
    if Block.isCurrentMove (Move.block move) && model.isDragging then
        Tile.view
            { boardSize = model.boardSize
            , window = model.context.window
            , settings = model.tileSettings
            , isBursting = Burst.isBursting model.board
            , withTracer = False
            }
            move

    else
        none


renderLines : Model -> Element msg
renderLines model =
    column [] (mapTiles (Line.view (lineViewModel model) >> html) model.board)


handleMoveEvents : Model -> Move -> Element.Attribute Msg
handleMoveEvents model move =
    Element.applyIf
        (not model.isDragging)
        (Touch.onStart (StartMove move))


mapTiles : (Move -> a) -> Board -> List a
mapTiles f =
    Board.moves >> List.map f



-- Info Window


infoWindow : Model -> Element Msg
infoWindow { info, context } =
    Info.view
        { content = infoContent context
        , info = info
        }


infoContent : Context -> LevelEndPrompt -> Element Msg
infoContent context prompt =
    case prompt of
        Success ->
            Text.text [ centerX, Text.white, Text.large ] (successMessage context)

        NoMovesLeft ->
            Text.text [ centerX, Text.white, Text.large ] "No more moves!"

        RestartAreYouSure ->
            areYouSure "Restart" RestartLevelLoseLife

        ExitAreYouSure ->
            areYouSure "Exit" ExitLevelLoseLife


successMessage : Context -> String
successMessage context =
    successMessages
        |> Dict.get (nextMessageIndex context)
        |> Maybe.withDefault "Win!"


nextMessageIndex : Context -> Int
nextMessageIndex context =
    modBy (Dict.size successMessages) context.successMessageIndex


successMessages : Dict Int String
successMessages =
    indexedDictFrom 0
        [ "Level Complete!"
        , "Success!"
        , "Win!"
        ]


areYouSure : String -> Msg -> Element Msg
areYouSure yesText msg =
    column []
        [ Text.text [] "Are you sure?"
        , Text.text [] "You will lose a life"
        , yesNoButton yesText msg
        ]


yesNoButton : String -> Msg -> Element Msg
yesNoButton yesText msg =
    Cancel.button
        { onCancel = HideInfo
        , onClick = msg
        , confirmText = yesText
        }



-- View Models


boardViewModel : Model -> Board.ViewModel
boardViewModel model =
    { window = model.context.window
    , boardSize = model.boardSize
    }


topBarViewModel : Model -> TopBar.Model
topBarViewModel model =
    { window = model.context.window
    , tileSettings = model.tileSettings
    , scores = model.scores
    , remainingMoves = model.remainingMoves
    }


lineViewModel : Model -> Line.ViewModel
lineViewModel model =
    { window = model.context.window
    , activeSeedType = Board.activeSeedType model.board
    }


lineDragViewModel : Model -> LineDrag.ViewModel
lineDragViewModel model =
    { window = model.context.window
    , board = model.board
    , tileSettings = model.tileSettings
    , isSeedPodMove = isSeedPodMove model
    , boardSize = model.boardSize
    , isDragging = model.isDragging
    , pointer = model.pointer
    }
