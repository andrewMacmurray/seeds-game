module Scene.Level exposing
    ( Model
    , Msg
    , Status(..)
    , init
    , menuOptions
    , update
    , view
    )

import Context exposing (Context)
import Delay
import Element exposing (..)
import Element.Button.Cancel as Cancel
import Element.Info as Info
import Element.Layout as Layout
import Element.Lazy as Lazy
import Element.Text as Text
import Element.Touch as Touch
import Exit exposing (continue, exitWith)
import Game.Board as Board exposing (Board)
import Game.Board.Block as Block exposing (Block)
import Game.Board.Coord exposing (Coord)
import Game.Board.Falling exposing (..)
import Game.Board.Generate as Generate
import Game.Board.Mechanic.Burst as Burst
import Game.Board.Mechanic.Pod as Pod
import Game.Board.Move as Move exposing (Move)
import Game.Board.Move.Move as Move
import Game.Board.Scores as Scores exposing (Scores)
import Game.Board.Shift as Board
import Game.Board.Tile exposing (State(..), Tile(..))
import Game.Board.Wall as Wall
import Game.Config.Level as Level
import Game.Level.Tile as Tile
import Game.Level.Tile.Constant as Start
import Game.Level.Tutorial as Tutorial exposing (Tutorial)
import Game.Lives as Lives
import Game.Messages as Messages
import Html exposing (Html, div)
import Scene.Level.Board as Board
import Scene.Level.Board.LineDrag as LineDrag
import Scene.Level.Board.Tile as Tile
import Scene.Level.Board.Tile.Line as Line
import Scene.Level.Board.Tile.Scale as Scale
import Scene.Level.TopBar as TopBar
import Scene.Level.Tutorial as Tutorial
import Seed
import Utils.Attribute as Attribute
import Utils.Element as Element
import Utils.Html.Style as Style
import Utils.Update as Update exposing (andCmds)
import View.Menu as Menu
import Window exposing (Window)



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
    | StartMove Touch.Point
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
        |> andCmds
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

        StartMove pointer ->
            continue (handleStartMove pointer model) []

        CheckMove pointer ->
            continue (checkMoveFromPoint pointer model) []

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
            continue (Update.withContext Context.closeMenu model) [ handleRestartPrompt model ]

        PromptExit ->
            continue (Update.withContext Context.closeMenu model) [ handleExitPrompt model ]

        LevelWon ->
            exitWith Win model

        LevelLost ->
            exitWith Lose model

        RestartLevel ->
            exitWith Restart model

        RestartLevelLoseLife ->
            exitWith Restart (Update.withContext Context.decrementLife model)

        ExitLevel ->
            exitWith Exit model

        ExitLevelLoseLife ->
            exitWith Exit (Update.withContext Context.decrementLife model)



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
    Update.trigger ReleaseTile


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
    if Tutorial.isInProgress model.tutorial then
        { model | tutorial = Tutorial.showStep model.tutorial }

    else
        model


handleTutorialStep : Model -> Exit.With Status ( Model, Cmd Msg )
handleTutorialStep model =
    handleTutorialStep_ model (Tutorial.nextStep model.tutorial)


handleTutorialStep_ : Model -> Tutorial -> Exit.With Status ( Model, Cmd Msg )
handleTutorialStep_ model next =
    continue { model | tutorial = next } [ triggerHideAutoStep next ]


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


handleStartMove : Touch.Point -> Model -> Model
handleStartMove pointer model =
    case moveFromPoint pointer model of
        Just move ->
            { model
                | isDragging = True
                , board = Move.drag model.boardSize move model.board
                , pointer = pointer
                , tutorial = Tutorial.hideStep model.tutorial
            }

        Nothing ->
            model


checkMoveFromPoint : Touch.Point -> Model -> Model
checkMoveFromPoint pointer model =
    case moveFromPoint pointer model of
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


moveFromPoint : Touch.Point -> Model -> Maybe Move
moveFromPoint pointer model =
    model
        |> coordsFromPosition pointer
        |> moveFromCoord model.board


moveFromCoord : Board -> Coord -> Maybe Move
moveFromCoord board coord =
    board
        |> Board.findBlockAt coord
        |> Maybe.map (Move.move coord)


coordsFromPosition : Touch.Point -> Model -> Coord
coordsFromPosition pointer model =
    let
        viewModel =
            { window = model.context.window
            , boardSize = model.boardSize
            }

        positionY =
            toFloat (pointer.y - Board.offsetTop viewModel)

        positionX =
            toFloat (pointer.x - Board.offsetLeft viewModel)

        scaleFactorY =
            toFloat (Scale.outerHeight model.context.window)

        scaleFactorX =
            toFloat (Scale.outerWidth model.context.window)
    in
    ( floor (positionY / scaleFactorY)
    , floor (positionX / scaleFactorX)
    )



-- Level End


checkLevelComplete : Model -> Exit.With Status ( Model, Cmd Msg )
checkLevelComplete model =
    let
        disableMenu =
            Update.withContext Context.disableMenu
    in
    if hasWon model then
        continue (disableMenu { model | levelStatus = Win }) [ winSequence ]

    else if hasLost model then
        continue (disableMenu { model | levelStatus = Lose }) [ loseSequence ]

    else
        continue { model | levelStatus = InProgress } []


hasLost : Model -> Bool
hasLost model =
    noMovesLeft model && model.levelStatus == InProgress


hasWon : Model -> Bool
hasWon model =
    scoreIsReached model && model.levelStatus == InProgress


levelIsOver : Model -> Bool
levelIsOver model =
    scoreIsReached model || noMovesLeft model


noMovesLeft : Model -> Bool
noMovesLeft model =
    model.remainingMoves < 1


scoreIsReached : Model -> Bool
scoreIsReached model =
    Scores.allComplete model.scores


handleExitPrompt : Model -> Cmd Msg
handleExitPrompt model =
    if model.levelStatus == NotStarted then
        Update.trigger ExitLevel

    else
        Update.trigger (ShowInfo ExitAreYouSure)


handleRestartPrompt : Model -> Cmd Msg
handleRestartPrompt model =
    if model.levelStatus == NotStarted then
        Update.trigger RestartLevel

    else
        Update.trigger (ShowInfo RestartAreYouSure)



-- View


view : Model -> Html Msg
view model =
    Layout.view
        [ handleStop model
        , handleCheck model
        , disableWhenLevelOver model
        , behindContent (topBar model)
        , inFront (renderBoard model)
        , inFront (lineDrag model)
        , inFront (currentMove model)
        , inFront (infoWindow model)
        , inFront (tutorialOverlay model)
        ]
        none


topBar : Model -> Element msg
topBar =
    topBarModel >> TopBar.view


handleStop : Model -> Element.Attribute Msg
handleStop model =
    Element.applyIf model.isDragging (Touch.onRelease StopMove)


handleCheck : Model -> Element.Attribute Msg
handleCheck model =
    Element.applyIf model.isDragging (Touch.onMove CheckMove)


disableWhenLevelOver : Model -> Element.Attribute msg
disableWhenLevelOver model =
    Element.applyIf (levelIsOver model) Element.disableTouch


lineDrag : Model -> Element msg
lineDrag =
    lineDragModel >> LineDrag.view



-- Tutorial Overlay


tutorialOverlay : Model -> Element msg
tutorialOverlay =
    tutorialViewModel >> Tutorial.view


tutorialViewModel : Model -> Tutorial.Model
tutorialViewModel model =
    { window = model.context.window
    , boardSize = model.boardSize
    , tileSettings = model.tileSettings
    , tutorial = model.tutorial
    }



-- Board


type alias LazyBoard msg =
    Window
    -> Board
    -> Board.Size
    -> List Tile.Setting
    -> Bool
    -> Element msg


type alias BoardModel =
    { window : Window
    , board : Board
    , boardSize : Board.Size
    , settings : List Tile.Setting
    , isDragging : Bool
    }


renderBoard : Model -> Element Msg
renderBoard model =
    el
        [ width fill
        , height fill
        , disableWhenLevelOver model
        ]
        (Lazy.lazy5
            toRenderBoard
            model.context.window
            model.board
            model.boardSize
            model.tileSettings
            model.isDragging
        )


toRenderBoard : LazyBoard Msg
toRenderBoard window board size settings isDragging =
    renderBoard_
        { window = window
        , board = board
        , boardSize = size
        , settings = settings
        , isDragging = isDragging
        }


renderBoard_ : BoardModel -> Element Msg
renderBoard_ model =
    el
        [ width (px (Board.width model))
        , moveDown (toFloat (Board.offsetTop model))
        , Element.preventScroll
        , centerX
        ]
        (html (div [] (mapTiles (renderTile model) model.board)))


renderTile : BoardModel -> Move -> Html Msg
renderTile model move =
    div []
        [ div
            [ handleStartMoveEvents model
            , Style.absolute
            , Style.zIndex 1
            , Style.pointer
            ]
            [ Tile.view
                { isBursting = Burst.isBursting model.board
                , boardSize = model.boardSize
                , window = model.window
                , settings = model.settings
                , move = move
                }
            ]
        , div
            [ Style.absolute
            , Style.zIndex 0
            ]
            [ Line.view
                { move = move
                , activeSeed = Board.activeSeedType model.board
                , window = model.window
                }
            ]
        ]


currentMove : Model -> Element msg
currentMove model =
    Lazy.lazy5
        toRenderCurrentMove
        model.context.window
        model.board
        model.boardSize
        model.tileSettings
        model.isDragging


toRenderCurrentMove : LazyBoard msg
toRenderCurrentMove window board size settings isDragging =
    currentMoveOverlay
        { window = window
        , board = board
        , boardSize = size
        , settings = settings
        , isDragging = isDragging
        }


currentMoveOverlay : BoardModel -> Element msg
currentMoveOverlay model =
    el
        [ Element.disableTouch
        , moveDown (toFloat (Board.offsetTop model))
        , width (px (Board.width model))
        , centerX
        ]
        (tilesFor currentMove_ model)


currentMove_ : BoardModel -> Move -> Html msg
currentMove_ model move =
    Tile.current
        { isDragging = model.isDragging
        , isBursting = Burst.isBursting model.board
        , boardSize = model.boardSize
        , window = model.window
        , settings = model.settings
        , move = move
        }


handleStartMoveEvents : BoardModel -> Html.Attribute Msg
handleStartMoveEvents model =
    Attribute.applyIf (not model.isDragging) (Touch.onStart_ StartMove)


tilesFor :
    ({ model | board : Board } -> Move -> Html msg)
    -> { model | board : Board }
    -> Element msg
tilesFor toTile model =
    html (div [] (mapTiles (toTile model) model.board))


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
successMessage =
    Messages.pickFrom "Win!"
        [ "Level Complete!"
        , "Success!"
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


topBarModel : Model -> TopBar.Model
topBarModel model =
    { window = model.context.window
    , tileSettings = model.tileSettings
    , scores = model.scores
    , remainingMoves = model.remainingMoves
    }


lineDragModel : Model -> LineDrag.Model
lineDragModel model =
    { window = model.context.window
    , board = model.board
    , boardSize = model.boardSize
    , isDragging = model.isDragging
    , point = model.pointer
    }
