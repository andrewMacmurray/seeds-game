module Scenes.Level exposing
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
import Board.Coord as Coord exposing (Coord)
import Board.Falling exposing (..)
import Board.Generate exposing (..)
import Board.Move as Move exposing (Move)
import Board.Move.Check exposing (addMoveToBoard, startMove)
import Board.Scores as Scores exposing (Scores)
import Board.Shift exposing (shiftBoard)
import Board.Tile as Tile exposing (State(..), Tile(..))
import Board.Wall as Wall
import Config.Level as Level
import Context exposing (Context)
import Css.Color as Color
import Css.Style as Style exposing (..)
import Css.Transform exposing (scale, translate)
import Css.Transition exposing (delay, transitionAll)
import Dict exposing (Dict)
import Exit exposing (continue, exitWith)
import Html exposing (Attribute, Html, div, p, span, text)
import Html.Attributes exposing (attribute, class)
import Html.Events exposing (onClick)
import InfoWindow exposing (InfoWindow)
import Level.Setting.Start as Start
import Level.Setting.Tile as Tile
import Lives
import Pointer exposing (Pointer, onPointerDown, onPointerMove, onPointerUp)
import Scenes.Level.LineDrag as LineDrag exposing (ViewModel)
import Scenes.Level.TopBar as TopBar
import Scenes.Level.Tutorial as Tutorial
import Seed exposing (Seed)
import Utils.Attribute as Attribute
import Utils.Delay as Delay exposing (sequence, trigger)
import Utils.Dict exposing (indexedDictFrom)
import Views.Board.Line exposing (renderLine)
import Views.Board.Style as Board
import Views.Board.Tile as Tile
import Views.InfoWindow
import Views.Menu as Menu



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
    , infoWindow : InfoWindow Info
    , pointer : Pointer
    }


type alias InitConfig =
    { walls : List Wall.Config
    , startTiles : List Start.Tile
    , randomTiles : List Tile
    }


type Msg
    = InitTiles InitConfig
    | StartTutorial
    | NextTutorialStep
    | HideTutorialStep
    | StopMove
    | StartMove Move Pointer
    | CheckMove Pointer
    | ReleaseTile
    | SetLeavingTiles
    | SetFallingTiles
    | SetGrowingSeedPods
    | GrowPodsToSeeds
    | AddGrowingSeeds Seed.Seed
    | ResetGrowingSeeds
    | BurstTiles
    | GenerateEnteringTiles RandomSetting
    | InsertEnteringTiles (List Tile)
    | ResetEntering
    | ShiftBoard
    | ResetMove
    | CheckLevelComplete
    | ShowInfo Info
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


type Info
    = Success
    | NoMovesLeft
    | RestartAreYouSure
    | ExitAreYouSure


type RandomSetting
    = AllTiles
    | AllButTileType Tile



-- Context


getContext : Model -> Context
getContext model =
    model.context


updateContext : (Context -> Context) -> Model -> Model
updateContext f model =
    { model | context = f model.context }


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
        |> withCmds
            [ handleGenerateInitialTiles config
            , handleStartTutorial
            ]


initialState : Level.LevelConfig -> Context -> Model
initialState { tileSettings, boardSize, moves, tutorial } context =
    { context = context
    , tutorial = tutorial
    , board = Board.fromMoves []
    , scores = Scores.init tileSettings
    , isDragging = False
    , remainingMoves = moves
    , tileSettings = tileSettings
    , boardSize = boardSize
    , levelStatus = NotStarted
    , infoWindow = InfoWindow.hidden
    , pointer = { y = 0, x = 0 }
    }


withCmds : List (model -> Cmd msg) -> model -> ( model, Cmd msg )
withCmds toCmds model =
    ( model
    , Cmd.batch <| List.map (\f -> f model) toCmds
    )


handleStartTutorial : Model -> Cmd Msg
handleStartTutorial _ =
    Delay.after 2800 StartTutorial



-- Update


update : Msg -> Model -> Exit.With Status ( Model, Cmd Msg )
update msg model =
    case msg of
        InitTiles config ->
            continue
                (model
                    |> createBoard config.randomTiles
                    |> updateBoard (addStartTiles config.startTiles)
                    |> updateBoard (Wall.addToBoard config.walls)
                )
                []

        StartTutorial ->
            continue { model | tutorial = Tutorial.showStep model.tutorial } []

        NextTutorialStep ->
            handleTutorialStep model

        HideTutorialStep ->
            continue { model | tutorial = Tutorial.hideStep model.tutorial } []

        StopMove ->
            continue model [ stopMoveSequence model ]

        ReleaseTile ->
            continue
                (model
                    |> stopDrag
                    |> handleResetTutorial
                    |> updateBlocks Block.setDraggingToStatic
                )
                []

        SetLeavingTiles ->
            continue
                (model
                    |> handleAddScore
                    |> updateBlocks Block.setDraggingToLeaving
                    |> updateBlocks Block.clearBurstType
                )
                []

        SetFallingTiles ->
            continue (updateBoard setFallingTiles model) []

        ShiftBoard ->
            continue
                (model
                    |> updateBoard shiftBoard
                    |> updateBlocks Block.setFallingToStatic
                    |> updateBlocks Block.setLeavingToEmpty
                )
                []

        SetGrowingSeedPods ->
            continue (updateBlocks Block.setDraggingToGrowing model) []

        GrowPodsToSeeds ->
            continue model [ generateRandomSeedType AddGrowingSeeds model.tileSettings ]

        AddGrowingSeeds seed ->
            continue
                (model
                    |> handleInsertNewSeeds seed
                    |> growLeavingBurstsToSeeds seed
                )
                []

        ResetGrowingSeeds ->
            continue (updateBlocks Block.setGrowingToStatic model) []

        GenerateEnteringTiles moveType ->
            continue model [ handleGenerateEnteringTiles moveType model.board model.tileSettings ]

        BurstTiles ->
            continue (updateBoard burstTiles model) []

        InsertEnteringTiles tiles ->
            continue (handleInsertEnteringTiles tiles model) []

        ResetEntering ->
            continue (updateBlocks Block.setEnteringToStatic model) []

        ResetMove ->
            continue
                (model
                    |> stopDrag
                    |> handleDecrementRemainingMoves
                )
                []

        StartMove move pointer ->
            continue (handleStartMove move pointer model) []

        CheckMove pointer ->
            continue (checkMoveFromPosition pointer model) []

        CheckLevelComplete ->
            handleCheckLevelComplete model

        HideInfo ->
            continue model [ hideInfoSequence ]

        ShowInfo info ->
            continue { model | infoWindow = InfoWindow.visible info } []

        InfoLeaving ->
            continue { model | infoWindow = InfoWindow.leaving model.infoWindow } []

        InfoHidden ->
            continue { model | infoWindow = InfoWindow.hidden } []

        PromptRestart ->
            continue model [ handleRestartPrompt model ]

        PromptExit ->
            continue model [ handleExitPrompt model ]

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


stopMoveSequence : Model -> Cmd Msg
stopMoveSequence model =
    let
        moveTileType =
            Board.currentTile model.board
    in
    if shouldRelease model.board then
        trigger ReleaseTile

    else if shouldBurst model.board then
        burstSequence moveTileType

    else if shouldGrowSeedPods moveTileType then
        growSeedPodsSequence

    else
        removeTilesSequence AllTiles


burstSequence : Maybe Tile -> Cmd Msg
burstSequence moveType =
    moveType
        |> Maybe.map AllButTileType
        |> Maybe.withDefault AllTiles
        |> burstTilesSequence moveType


shouldRelease : Board -> Bool
shouldRelease board =
    List.length (Board.currentMoves board) == 1


shouldGrowSeedPods : Maybe Tile -> Bool
shouldGrowSeedPods moveTileType =
    moveTileType == Just SeedPod


shouldBurst : Board -> Bool
shouldBurst =
    Board.currentMoves >> List.any (Move.block >> Block.isBurst)


growSeedPodsSequence : Cmd Msg
growSeedPodsSequence =
    sequence
        [ ( 0, ResetMove )
        , ( 0, SetGrowingSeedPods )
        , ( 800, GrowPodsToSeeds )
        , ( 0, CheckLevelComplete )
        , ( 600, ResetGrowingSeeds )
        , ( 500, NextTutorialStep )
        ]


removeTilesSequence : RandomSetting -> Cmd Msg
removeTilesSequence enteringTiles =
    sequence
        [ ( 0, ResetMove )
        , ( 0, SetLeavingTiles )
        , ( 350, SetFallingTiles )
        , ( 500, ShiftBoard )
        , ( 0, CheckLevelComplete )
        , ( 0, GenerateEnteringTiles enteringTiles )
        , ( 500, ResetEntering )
        , ( 500, NextTutorialStep )
        ]


burstTilesSequence : Maybe Tile -> RandomSetting -> Cmd Msg
burstTilesSequence moveType enteringTiles =
    case moveType of
        Just SeedPod ->
            sequence
                [ ( 0, ResetMove )
                , ( 0, BurstTiles )
                , ( 700, SetGrowingSeedPods )
                , ( 800, GrowPodsToSeeds )
                , ( 0, CheckLevelComplete )
                , ( 600, ResetGrowingSeeds )
                , ( 500, NextTutorialStep )
                ]

        _ ->
            sequence
                [ ( 0, ResetMove )
                , ( 0, BurstTiles )
                , ( 700, SetLeavingTiles )
                , ( 550, SetFallingTiles )
                , ( 500, ShiftBoard )
                , ( 0, CheckLevelComplete )
                , ( 0, GenerateEnteringTiles enteringTiles )
                , ( 500, ResetEntering )
                , ( 500, NextTutorialStep )
                ]


winSequence : Cmd Msg
winSequence =
    sequence
        [ ( 500, ShowInfo Success )
        , ( 2000, HideInfo )
        , ( 1000, LevelWon )
        ]


loseSequence : Cmd Msg
loseSequence =
    sequence
        [ ( 500, ShowInfo NoMovesLeft )
        , ( 2000, HideInfo )
        , ( 1000, LevelLost )
        ]


hideInfoSequence : Cmd Msg
hideInfoSequence =
    sequence
        [ ( 0, InfoLeaving )
        , ( 1000, InfoHidden )
        ]



-- Update Helpers


type alias HasBoard model =
    { model | board : Board, boardSize : Board.Size }


updateBlocks : (Block -> Block) -> HasBoard model -> HasBoard model
updateBlocks f model =
    { model | board = Board.updateBlocks f model.board }


updateBoard : (Board -> Board) -> HasBoard model -> HasBoard model
updateBoard f model =
    { model | board = f model.board }


addStartTiles : List Start.Tile -> Board -> Board
addStartTiles startTiles board =
    List.foldl (Board.place << Start.move) board startTiles


handleGenerateInitialTiles : Level.LevelConfig -> Model -> Cmd Msg
handleGenerateInitialTiles config { boardSize } =
    generateInitialTiles
        (InitTiles << InitConfig config.walls config.startTiles)
        config.tileSettings
        boardSize


handleGenerateEnteringTiles : RandomSetting -> Board -> List Tile.Setting -> Cmd Msg
handleGenerateEnteringTiles enteringTiles board tileSettings =
    case enteringTiles of
        AllTiles ->
            generateEntering board tileSettings

        AllButTileType tileType ->
            generateEnteringTilesWithoutTileType tileType board tileSettings


generateEnteringTilesWithoutTileType : Tile -> Board -> List Tile.Setting -> Cmd Msg
generateEnteringTilesWithoutTileType tileType board tileSettings =
    if List.length tileSettings == 1 then
        generateEntering board tileSettings

    else
        tileType
            |> filterSettings tileSettings
            |> generateEntering board


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

        triggerHideAutoStep =
            if Tutorial.isAutoStep nextTutorial then
                Delay.after 3000 HideTutorialStep

            else
                Cmd.none
    in
    continue { model | tutorial = nextTutorial } [ triggerHideAutoStep ]


filterSettings : List Tile.Setting -> Tile -> List Tile.Setting
filterSettings settings tile =
    List.filter (\setting -> setting.tileType /= tile) settings


generateEntering : Board -> List Tile.Setting -> Cmd Msg
generateEntering =
    generateEnteringTiles InsertEnteringTiles


createBoard : List Tile -> HasBoard model -> HasBoard model
createBoard tiles model =
    { model | board = Board.fromTiles model.boardSize tiles }


handleInsertEnteringTiles : List Tile -> HasBoard model -> HasBoard model
handleInsertEnteringTiles tiles =
    updateBoard <| insertNewEnteringTiles tiles


handleInsertNewSeeds : Seed -> HasBoard model -> HasBoard model
handleInsertNewSeeds =
    updateBoard << insertNewSeeds


growLeavingBurstsToSeeds : Seed -> HasBoard model -> HasBoard model
growLeavingBurstsToSeeds seed =
    updateBlocks (Block.growLeavingBurstToSeed seed)


handleAddScore : Model -> Model
handleAddScore model =
    { model | scores = Scores.addScoreFromMoves model.board model.scores }


stopDrag : Model -> Model
stopDrag model =
    { model | isDragging = False }


handleDecrementRemainingMoves : Model -> Model
handleDecrementRemainingMoves model =
    if model.remainingMoves < 1 then
        { model | remainingMoves = 0 }

    else
        { model | remainingMoves = model.remainingMoves - 1 }


handleStartMove : Move -> Pointer -> Model -> Model
handleStartMove move pointer model =
    { model
        | isDragging = True
        , board = startMove move model.board
        , pointer = pointer
        , tutorial = Tutorial.hideStep model.tutorial
    }


checkMoveFromPosition : Pointer -> Model -> Model
checkMoveFromPosition pointer model =
    case moveFromPosition pointer model of
        Just move ->
            handleCheckMove move { model | pointer = pointer }

        Nothing ->
            { model | pointer = pointer }


handleCheckMove : Move -> Model -> Model
handleCheckMove move model =
    if model.isDragging then
        model
            |> updateBoard (addMoveToBoard move)
            |> handleAddBurstType
            |> updateBoard (addActiveTiles model.boardSize)

    else
        model



-- Burst


addActiveTiles : Board.Size -> Board -> Board
addActiveTiles size board =
    let
        burstRadius =
            burstMagnitude board

        burstCoords =
            burstCoordinates board

        burstAreaCoordinates =
            burstCoords
                |> List.map (Coord.surrounding size burstRadius)
                |> List.concat

        withinBurstArea move =
            List.member (Move.coord move) burstAreaCoordinates

        nonBurstingMove move =
            not (withinBurstArea move) || tile /= Move.tile move

        nonBurstCoords =
            Board.moves board
                |> List.filter nonBurstingMove
                |> List.map Move.coord

        tile =
            Board.currentTile board

        updateBlockToActive b =
            if tile == Block.tile b then
                Block.setToActive b

            else
                b

        updateToActive coord =
            Board.updateAt coord updateBlockToActive

        updateToStatic coord =
            Board.updateAt coord Block.setActiveToStatic
    in
    List.foldl updateToActive board burstAreaCoordinates
        |> (\updatedBoard -> List.foldl updateToStatic updatedBoard nonBurstCoords)


handleAddBurstType : Model -> Model
handleAddBurstType model =
    case Board.currentTile model.board of
        Just moveType ->
            updateBlocks (Block.setDraggingBurstType moveType) model

        Nothing ->
            updateBlocks Block.clearBurstType model


burstTiles : Board -> Board
burstTiles board =
    let
        burstCoords =
            burstCoordinates board

        withMoveOrder coord =
            Coord.x coord + 1 * (Coord.y coord * 8)

        updateActiveBlockToDragging coord block =
            case Block.tileState block of
                Active _ ->
                    Block.setToDragging (withMoveOrder coord) block

                _ ->
                    block

        updateBurstsToLeaving coord =
            Board.updateAt coord Block.setDraggingToLeaving

        updatedDraggingBoard =
            Board.update updateActiveBlockToDragging board
    in
    burstCoords
        |> List.foldl updateBurstsToLeaving updatedDraggingBoard
        |> Board.updateBlocks Block.clearBearing


burstMagnitude : Board -> Int
burstMagnitude board =
    let
        currMoves =
            Board.currentMoves board

        numberOfBurstTiles =
            currMoves
                |> List.filter (Move.block >> Block.isBurst)
                |> List.length
    in
    List.length currMoves // 2 + numberOfBurstTiles


burstCoordinates : Board -> List Coord
burstCoordinates board =
    Board.currentMoves board
        |> List.filter (Move.block >> Block.isBurst)
        |> List.map Move.coord



-- Get Move from position


moveFromPosition : Pointer -> Model -> Maybe Move
moveFromPosition pointer model =
    moveFromCoord model.board <| coordsFromPosition pointer model


moveFromCoord : Board -> Coord -> Maybe Move
moveFromCoord board coord =
    board
        |> Board.findBlockAt coord
        |> Maybe.map (Move.move coord)


coordsFromPosition : Pointer -> Model -> Coord
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


handleCheckLevelComplete : Model -> Exit.With Status ( Model, Cmd Msg )
handleCheckLevelComplete model =
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
        trigger ExitLevel

    else
        trigger <| ShowInfo ExitAreYouSure


handleRestartPrompt : Model -> Cmd Msg
handleRestartPrompt model =
    if model.levelStatus == NotStarted then
        trigger RestartLevel

    else
        trigger <| ShowInfo RestartAreYouSure



-- VIEW


view : Model -> Html Msg
view model =
    div
        [ handleStop model
        , handleCheck model
        , disableIfComplete model
        ]
        [ topBar model
        , tutorialOverlay model
        , renderInfoWindow model
        , currentMoveOverlay model
        , lineDrag model
        , renderBoard model
        , moveCaptureArea
        ]


topBar : Model -> Html msg
topBar =
    topBarViewModel >> TopBar.view


handleStop : Model -> Attribute Msg
handleStop model =
    Attribute.applyIf model.isDragging <| onPointerUp StopMove


handleCheck : Model -> Attribute Msg
handleCheck model =
    Attribute.applyIf model.isDragging <| onPointerMove CheckMove


disableIfComplete : Model -> Attribute msg
disableIfComplete model =
    Attribute.applyIf (Scores.allComplete model.scores) <| class "touch-disabled"


moveCaptureArea : Html msg
moveCaptureArea =
    div [ class "w-100 h-100 fixed z-1 top-0" ] []


lineDrag : Model -> Html msg
lineDrag =
    lineDragViewModel >> LineDrag.view



-- Tutorial Overlay


tutorialOverlay : Model -> Html msg
tutorialOverlay =
    Tutorial.view << tutorialViewModel


tutorialViewModel : Model -> Tutorial.ViewModel
tutorialViewModel model =
    { window = model.context.window
    , boardSize = model.boardSize
    , tutorial = model.tutorial
    }



-- Board


renderBoard : Model -> Html Msg
renderBoard model =
    boardLayout model
        [ div [ class "relative z-5" ] <| renderTiles model
        , div [ class "absolute top-0 left-0 z-0" ] <| renderLines model
        ]


renderTiles : Model -> List (Html Msg)
renderTiles model =
    mapTiles (renderTile model) model.board


renderTile : Model -> Move -> Html Msg
renderTile model move =
    div
        [ handleMoveEvents model move
        , class "pointer"
        , attribute "touch-action" "none"
        ]
        [ Tile.view
            { isBursting = isBursting model
            , extraStyles = leavingStyles model move
            , withTracer = True
            }
            model.context.window
            move
        ]


isBursting : Model -> Bool
isBursting model =
    model.board
        |> Board.blocks
        |> List.any (\b -> Block.isBurst b && Block.isLeaving b)


currentMoveOverlay : Model -> Html msg
currentMoveOverlay model =
    let
        viewModel =
            boardViewModel model

        moveLayer =
            currentMoveLayer model
    in
    div
        [ style
            [ Style.width <| toFloat <| Board.width viewModel
            , top <| toFloat <| Board.offsetTop viewModel
            ]
        , class "z-6 touch-disabled absolute left-0 right-0 flex center"
        ]
        moveLayer


currentMoveLayer : Model -> List (Html msg)
currentMoveLayer model =
    mapTiles (renderCurrentMove model) model.board


renderCurrentMove : Model -> Move -> Html msg
renderCurrentMove model move =
    if Block.isCurrentMove (Move.block move) && model.isDragging then
        Tile.view
            { extraStyles = []
            , isBursting = isBursting model
            , withTracer = False
            }
            model.context.window
            move

    else
        span [] []


renderLines : Model -> List (Html msg)
renderLines model =
    mapTiles (renderLine model.context.window) model.board


boardLayout : Model -> List (Html msg) -> Html msg
boardLayout model =
    div
        [ style
            [ width <| toFloat <| Board.width <| boardViewModel model
            , Board.marginTop <| boardViewModel model
            ]
        , class "relative z-3 center flex flex-wrap"
        ]


handleMoveEvents : Model -> Move -> Attribute Msg
handleMoveEvents model move =
    Attribute.applyIf (not model.isDragging) <| onPointerDown <| StartMove move


mapTiles : (Move -> a) -> Board -> List a
mapTiles f =
    Board.moves >> List.map f



-- Leaving Styles


leavingStyles : Model -> Move -> List Style
leavingStyles model move =
    let
        block =
            Move.block move
    in
    if Block.isLeaving block && not (Block.isBurst block) then
        [ transitionAll 800 [ delay <| modBy 5 (Block.leavingOrder block) * 80 ]
        , opacity 0.2
        , handleExitDirection move model
        ]

    else
        []


handleExitDirection : Move -> Model -> Style
handleExitDirection move model =
    case Block.tileState <| Move.block move of
        Leaving Rain _ ->
            getLeavingStyle Rain model

        Leaving Sun _ ->
            getLeavingStyle Sun model

        Leaving (Seed seedType) _ ->
            getLeavingStyle (Seed seedType) model

        _ ->
            Style.none


getLeavingStyle : Tile -> Model -> Style
getLeavingStyle tileType model =
    newLeavingStyles model
        |> Dict.get (Tile.hash tileType)
        |> Maybe.withDefault Style.none


newLeavingStyles : Model -> Dict.Dict String Style
newLeavingStyles model =
    model.tileSettings
        |> Scores.tileTypes
        |> List.indexedMap (prepareLeavingStyle model)
        |> Dict.fromList


prepareLeavingStyle : Model -> Int -> Tile -> ( String, Style )
prepareLeavingStyle model resourceBankIndex tileType =
    ( Tile.hash tileType
    , transform
        [ translate (exitXDistance resourceBankIndex model) -(exitYDistance (boardViewModel model))
        , scale 0.5
        ]
    )


exitXDistance : Int -> Model -> Float
exitXDistance resourceBankIndex model =
    let
        scoreWidth =
            Board.scoreIconSize * 2

        scoreBarWidth =
            model.tileSettings
                |> List.filter Scores.collectible
                |> List.length
                |> (*) scoreWidth

        baseOffset =
            (Board.width (boardViewModel model) - scoreBarWidth) // 2

        offset =
            exitOffsetFunction <| Tile.scale model.context.window
    in
    toFloat (baseOffset + resourceBankIndex * scoreWidth) + offset


exitOffsetFunction : Float -> Float
exitOffsetFunction x =
    25 * (x ^ 2) - (75 * x) + Tile.baseSizeX


exitYDistance : Board.ViewModel -> Float
exitYDistance model =
    toFloat (Board.offsetTop model) - 9



-- Info Window


renderInfoWindow : Model -> Html Msg
renderInfoWindow { infoWindow, context } =
    InfoWindow.content infoWindow
        |> Maybe.map (renderInfoContent context.successMessageIndex)
        |> Maybe.map (infoContainer infoWindow)
        |> Maybe.withDefault (span [] [])


infoContainer : InfoWindow Info -> Html Msg -> Html Msg
infoContainer infoWindow rendered =
    case InfoWindow.content infoWindow of
        Just RestartAreYouSure ->
            div [ onClick HideInfo ] [ Views.InfoWindow.infoContainer infoWindow rendered ]

        Just ExitAreYouSure ->
            div [ onClick HideInfo ] [ Views.InfoWindow.infoContainer infoWindow rendered ]

        _ ->
            Views.InfoWindow.infoContainer infoWindow rendered


renderInfoContent : Int -> Info -> Html Msg
renderInfoContent successMessageIndex infoContent =
    case infoContent of
        Success ->
            div [ class "pv5 f3 tracked-mega" ] [ text <| successMessage successMessageIndex ]

        NoMovesLeft ->
            div [ class "pv5 f3 tracked-mega" ] [ text "No more moves!" ]

        RestartAreYouSure ->
            areYouSure "Restart" RestartLevelLoseLife

        ExitAreYouSure ->
            areYouSure "Exit" ExitLevelLoseLife


successMessage : Int -> String
successMessage i =
    let
        ii =
            modBy (Dict.size successMessages) i
    in
    Dict.get ii successMessages |> Maybe.withDefault "Win!"


successMessages : Dict Int String
successMessages =
    indexedDictFrom 0
        [ "Level Complete!"
        , "Success!"
        , "Win!"
        ]


areYouSure : String -> Msg -> Html Msg
areYouSure yesText msg =
    div [ class "pv4" ]
        [ p [ class "f3 ma0 tracked" ] [ text "Are you sure?" ]
        , p [ class "f7 tracked", style [ marginTop 15, marginBottom 35 ] ] [ text "You will lose a life" ]
        , yesNoButton yesText msg
        ]


yesNoButton : String -> Msg -> Html Msg
yesNoButton yesText msg =
    div []
        [ div
            [ class "dib ttu tracked-mega f6"
            , onClick HideInfo
            , style
                [ color Color.white
                , backgroundColor Color.firrGreen
                , paddingLeft 25
                , paddingRight 15
                , paddingTop 10
                , paddingBottom 10
                , leftPill
                ]
            ]
            [ text "X" ]
        , div
            [ class "dib ttu tracked-mega f6"
            , onClick msg
            , style
                [ color Color.white
                , backgroundColor Color.gold
                , paddingLeft 15
                , paddingRight 20
                , paddingTop 10
                , paddingBottom 10
                , rightPill
                ]
            ]
            [ text yesText ]
        ]



-- View Models


boardViewModel : Model -> Board.ViewModel
boardViewModel model =
    { window = model.context.window
    , boardSize = model.boardSize
    }


topBarViewModel : Model -> TopBar.ViewModel
topBarViewModel model =
    { window = model.context.window
    , tileSettings = model.tileSettings
    , scores = model.scores
    , remainingMoves = model.remainingMoves
    }


lineDragViewModel : Model -> LineDrag.ViewModel
lineDragViewModel model =
    { window = model.context.window
    , board = model.board
    , boardSize = model.boardSize
    , isDragging = model.isDragging
    , pointer = model.pointer
    }
