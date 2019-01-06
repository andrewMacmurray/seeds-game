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

import Browser.Events
import Context exposing (Context)
import Css.Animation as Animation
import Css.Color as Color exposing (Color)
import Css.Style as Style exposing (..)
import Css.Transform exposing (scale, translate)
import Css.Transition exposing (delay, transitionAll)
import Data.Board.Block as Block
import Data.Board.Falling exposing (..)
import Data.Board.Generate exposing (..)
import Data.Board.Map exposing (..)
import Data.Board.Move as Move
import Data.Board.Move.Check exposing (addMoveToBoard, startMove)
import Data.Board.Score as Score exposing (addScoreFromMoves, initialScores, levelComplete, scoreTileTypes)
import Data.Board.Shift exposing (shiftBoard)
import Data.Board.Tile as Tile
import Data.Board.Types exposing (..)
import Data.Board.Wall exposing (addWalls)
import Data.InfoWindow as InfoWindow exposing (InfoWindow)
import Data.Level.Setting exposing (TileSetting)
import Data.Levels as Levels
import Data.Lives as Lives
import Data.Pointer exposing (Pointer, onPointerDown, onPointerMove, onPointerUp)
import Data.Window exposing (Window)
import Dict exposing (Dict)
import Exit exposing (continue, exitWith)
import Helpers.Attribute as Attribute
import Helpers.Delay exposing (sequence, trigger)
import Helpers.Dict exposing (filterValues, indexedDictFrom, mapValues)
import Html exposing (Attribute, Html, div, p, span, text)
import Html.Attributes exposing (attribute, class)
import Html.Events exposing (onClick)
import Scenes.Level.LineDrag exposing (LineViewModel, handleLineDrag)
import Scenes.Level.TopBar exposing (TopBarViewModel, remainingMoves, topBar)
import Task
import Views.Board.Line exposing (renderLine)
import Views.Board.Styles exposing (..)
import Views.Board.Tile exposing (renderTile_)
import Views.InfoWindow
import Views.Menu as Menu



-- Model


type alias Model =
    { context : Context
    , board : Board
    , scores : Scores
    , isDragging : Bool
    , remainingMoves : Int
    , tileSettings : List TileSetting
    , boardDimensions : BoardDimensions
    , levelStatus : Status
    , infoWindow : InfoWindow InfoContent
    , pointer : Pointer
    }


type Msg
    = InitTiles (List ( Color, Coord )) (List TileType)
    | StopMove
    | StartMove Move Pointer
    | CheckMove Pointer
    | ReleaseTile
    | ResetReleasingTile
    | SetLeavingTiles
    | SetFallingTiles
    | SetGrowingSeedPods
    | GrowPodsToSeeds
    | InsertGrowingSeeds SeedType
    | ResetGrowingSeeds
    | BurstTiles
    | GenerateEnteringTiles
    | InsertEnteringTiles (List TileType)
    | ResetEntering
    | ShiftBoard
    | ResetMove
    | CheckLevelComplete
    | ShowInfo InfoContent
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


type InfoContent
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


init : Levels.LevelConfig -> Context -> ( Model, Cmd Msg )
init config context =
    let
        model =
            context
                |> initialState
                |> addLevelData config
    in
    ( model
    , handleGenerateTiles config model
    )


addLevelData : Levels.LevelConfig -> Model -> Model
addLevelData { tiles, walls, boardDimensions, moves } model =
    { model
        | scores = initialScores tiles
        , board = addWalls walls model.board
        , boardDimensions = boardDimensions
        , tileSettings = tiles
        , remainingMoves = moves
    }


initialState : Context -> Model
initialState context =
    { context = context
    , board = Dict.empty
    , scores = Dict.empty
    , isDragging = False
    , remainingMoves = 10
    , tileSettings = []
    , boardDimensions = { y = 8, x = 8 }
    , levelStatus = NotStarted
    , infoWindow = InfoWindow.hidden
    , pointer = { y = 0, x = 0 }
    }



-- Update


update : Msg -> Model -> Exit.With Status ( Model, Cmd Msg )
update msg model =
    case msg of
        InitTiles walls tiles ->
            continue
                (model
                    |> handleMakeBoard tiles
                    |> mapBoard (addWalls walls)
                )
                []

        StopMove ->
            continue model [ stopMoveSequence model ]

        SetLeavingTiles ->
            continue
                (model
                    |> handleAddScore
                    |> mapBlocks Block.setToLeaving
                )
                []

        ReleaseTile ->
            continue
                (model
                    |> stopDrag
                    |> mapBlocks Block.setDraggingToReleasing
                )
                []

        SetFallingTiles ->
            continue (mapBoard setFallingTiles model) []

        ShiftBoard ->
            continue
                (model
                    |> mapBoard shiftBoard
                    |> mapBlocks Block.setFallingToStatic
                    |> mapBlocks Block.setLeavingToEmpty
                )
                []

        SetGrowingSeedPods ->
            continue (mapBlocks Block.setDraggingToGrowing model) []

        GrowPodsToSeeds ->
            continue model [ generateRandomSeedType InsertGrowingSeeds model.tileSettings ]

        InsertGrowingSeeds seedType ->
            continue (handleInsertNewSeeds seedType model) []

        ResetGrowingSeeds ->
            continue (mapBlocks Block.setGrowingToStatic model) []

        GenerateEnteringTiles ->
            continue model [ generateEnteringTiles InsertEnteringTiles model.tileSettings model.board ]

        BurstTiles ->
            continue (mapBoard (setBurstingTiles model.boardDimensions) model) []

        InsertEnteringTiles tiles ->
            continue (handleInsertEnteringTiles tiles model) []

        ResetEntering ->
            continue (mapBlocks Block.setEnteringToStatic model) []

        ResetMove ->
            continue
                (model
                    |> stopDrag
                    |> handleDecrementRemainingMoves
                )
                []

        ResetReleasingTile ->
            continue (mapBlocks Block.setReleasingToStatic model) []

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
    if List.length (Move.currentMoves model.board) == 1 then
        releaseTileSequence

    else if shouldBurst model.board then
        burstTilesSequence

    else if Move.currentMoveTileType model.board == Just SeedPod then
        growSeedPodsSequence

    else
        removeTilesSequence


growSeedPodsSequence : Cmd Msg
growSeedPodsSequence =
    sequence
        [ ( 0, ResetMove )
        , ( 0, SetGrowingSeedPods )
        , ( 800, GrowPodsToSeeds )
        , ( 0, CheckLevelComplete )
        , ( 600, ResetGrowingSeeds )
        ]


removeTilesSequence : Cmd Msg
removeTilesSequence =
    sequence
        [ ( 0, ResetMove )
        , ( 0, SetLeavingTiles )
        , ( 350, SetFallingTiles )
        , ( 500, ShiftBoard )
        , ( 0, CheckLevelComplete )
        , ( 0, GenerateEnteringTiles )
        , ( 500, ResetEntering )
        ]


burstTilesSequence : Cmd Msg
burstTilesSequence =
    sequence
        [ ( 0, ResetMove )
        , ( 0, BurstTiles )
        , ( 700, SetLeavingTiles )
        , ( 550, SetFallingTiles )
        , ( 500, ShiftBoard )
        , ( 0, CheckLevelComplete )
        , ( 0, GenerateEnteringTiles )
        , ( 500, ResetEntering )
        ]


releaseTileSequence =
    sequence
        [ ( 0, ReleaseTile )
        , ( 200, ResetReleasingTile )
        ]


winSequence : Model -> Cmd Msg
winSequence model =
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
    { model | board : Board, boardDimensions : BoardDimensions }


handleGenerateTiles : Levels.LevelConfig -> Model -> Cmd Msg
handleGenerateTiles config { boardDimensions } =
    generateInitialTiles (InitTiles config.walls) config.tiles boardDimensions


handleMakeBoard : List TileType -> HasBoard model -> HasBoard model
handleMakeBoard tiles ({ boardDimensions } as model) =
    { model | board = makeBoard boardDimensions tiles }


handleInsertEnteringTiles : List TileType -> HasBoard model -> HasBoard model
handleInsertEnteringTiles tiles =
    mapBoard <| insertNewEnteringTiles tiles


handleInsertNewSeeds : SeedType -> HasBoard model -> HasBoard model
handleInsertNewSeeds seedType =
    mapBoard <| insertNewSeeds seedType


handleAddScore : Model -> Model
handleAddScore model =
    { model | scores = addScoreFromMoves model.board model.scores }


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
handleStartMove (( _, block ) as move) pointer model =
    if Block.isReleasing block then
        model

    else
        { model
            | isDragging = True
            , board = startMove move model.board
            , pointer = pointer
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
        handleAddBurstType { model | board = addMoveToBoard move model.board }

    else
        model


handleAddBurstType : Model -> Model
handleAddBurstType model =
    case Move.currentMoveTileType model.board of
        Just moveType ->
            mapBlocks (Block.setDraggingBurstType moveType) model

        Nothing ->
            mapBlocks Block.resetDraggingBurstType model


shouldBurst : Board -> Bool
shouldBurst board =
    board
        |> Move.currentMoves
        |> List.any (Move.block >> Block.isBurst)


setBurstingTiles : BoardDimensions -> Board -> Board
setBurstingTiles dimensions board =
    let
        currMoves =
            Move.currentMoves board

        burstRadius =
            burstMagnitude board

        burstCoords =
            currMoves
                |> List.filter (Move.block >> Block.isBurst)
                |> List.map Move.coord

        burstArea =
            burstCoords
                |> List.map (Move.surroundingCoordinates dimensions burstRadius)
                |> List.concat

        moveType =
            Move.currentMoveTileType board

        updateBlockToDragging b =
            if moveType == Block.getTileType b then
                Block.setToDragging 1 b

            else
                b

        updateToDragging mv acc =
            Dict.update mv (Maybe.map updateBlockToDragging) acc

        updateBurstsToLeaving mv =
            Dict.update mv (Maybe.map Block.setToLeaving)
    in
    List.foldl updateBurstsToLeaving (List.foldl updateToDragging board burstArea) burstCoords
        |> mapValues Block.removeBearing


burstMagnitude : Board -> Int
burstMagnitude board =
    let
        currMoves =
            Move.currentMoves board

        burstCoords =
            currMoves
                |> List.filter (Move.block >> Block.isBurst)
                |> List.map Move.coord
    in
    List.length currMoves // 2 + List.length burstCoords


moveFromPosition : Pointer -> Model -> Maybe Move
moveFromPosition pointer model =
    moveFromCoord model.board <| coordsFromPosition pointer model


moveFromCoord : Board -> Coord -> Maybe Move
moveFromCoord board coord =
    board |> Dict.get coord |> Maybe.map (\b -> ( coord, b ))


coordsFromPosition : Pointer -> Model -> Coord
coordsFromPosition pointer model =
    let
        tileViewModel_ =
            ( model.context.window, model.boardDimensions )

        positionY =
            toFloat <| pointer.y - boardOffsetTop tileViewModel_

        positionX =
            toFloat <| pointer.x - boardOffsetLeft tileViewModel_

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
        continue (disableMenu { model | levelStatus = Win }) [ winSequence model ]

    else if hasLost model then
        continue (disableMenu { model | levelStatus = Lose }) [ loseSequence ]

    else
        continue { model | levelStatus = InProgress } []


hasLost : Model -> Bool
hasLost { remainingMoves, levelStatus } =
    remainingMoves < 1 && levelStatus == InProgress


hasWon : Model -> Bool
hasWon { scores, levelStatus } =
    levelComplete scores && levelStatus == InProgress


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
        [ topBar <| topBarViewModel model
        , renderInfoWindow model
        , currentMoveOverlay model <| currentMoveLayer model
        , handleLineDrag <| lineViewModel model
        , renderBoard model
        , moveCaptureArea
        ]


handleStop : Model -> Attribute Msg
handleStop model =
    Attribute.applyIf model.isDragging <| onPointerUp StopMove


handleCheck : Model -> Attribute Msg
handleCheck model =
    Attribute.applyIf model.isDragging <| onPointerMove CheckMove


disableIfComplete : Model -> Attribute msg
disableIfComplete model =
    Attribute.applyIf (levelComplete model.scores) <| class "touch-disabled"


moveCaptureArea : Html msg
moveCaptureArea =
    div [ class "w-100 h-100 fixed z-1 top-0" ] []



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
renderTile model (( _, block ) as move) =
    div
        [ hanldeMoveEvents model move
        , class "pointer"
        , attribute "touch-action" "none"
        ]
        [ renderTile_
            { externalDragTriggered = isBursting model
            , burstMagnitude = burstMagnitude model.board
            , extraStyles = leavingStyles model move
            , withTracer = True
            }
            model.context.window
            move
        ]


isBursting model =
    let
        bursting =
            model.board
                |> Dict.values
                |> List.any (\b -> Block.isBurst b && Block.isLeaving b)
    in
    not model.isDragging && bursting


currentMoveOverlay : Model -> List (Html msg) -> Html msg
currentMoveOverlay model =
    let
        vm =
            tileViewModel model
    in
    div
        [ style
            [ width <| toFloat <| boardWidth vm
            , top <| toFloat <| boardOffsetTop vm
            ]
        , class "z-6 touch-disabled absolute left-0 right-0 flex center"
        ]


currentMoveLayer : Model -> List (Html msg)
currentMoveLayer model =
    mapTiles (renderCurrentMove model) model.board


renderCurrentMove : Model -> Move -> Html msg
renderCurrentMove model (( _, block ) as move) =
    if Block.isCurrentMove block && model.isDragging then
        renderTile_
            { extraStyles = []
            , externalDragTriggered = isBursting model
            , burstMagnitude = 1
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
            [ width <| toFloat <| boardWidth <| tileViewModel model
            , boardMarginTop <| tileViewModel model
            ]
        , class "relative z-3 center flex flex-wrap"
        ]


hanldeMoveEvents : Model -> Move -> Attribute Msg
hanldeMoveEvents model move =
    Attribute.applyIf (not model.isDragging) <| onPointerDown <| StartMove move


mapTiles : (Move -> a) -> Board -> List a
mapTiles f =
    Dict.toList >> List.map f



-- Leaving Styles


leavingStyles : Model -> Move -> List Style
leavingStyles model (( _, block ) as move) =
    if Block.isLeaving block && not (Block.isBurst block) then
        [ transitionAll 800 [ delay <| modBy 5 (Block.leavingOrder block) * 80 ]
        , opacity 0.2
        , handleExitDirection move model
        ]

    else
        []


handleExitDirection : Move -> Model -> Style
handleExitDirection ( coord, block ) model =
    case Block.getTileState block of
        Leaving Rain _ ->
            getLeavingStyle Rain model

        Leaving Sun _ ->
            getLeavingStyle Sun model

        Leaving (Seed seedType) _ ->
            getLeavingStyle (Seed seedType) model

        _ ->
            Style.empty


getLeavingStyle : TileType -> Model -> Style
getLeavingStyle tileType model =
    newLeavingStyles model
        |> Dict.get (Tile.hash tileType)
        |> Maybe.withDefault Style.empty


newLeavingStyles : Model -> Dict.Dict String Style
newLeavingStyles model =
    model.tileSettings
        |> scoreTileTypes
        |> List.indexedMap (prepareLeavingStyle model)
        |> Dict.fromList


prepareLeavingStyle : Model -> Int -> TileType -> ( String, Style )
prepareLeavingStyle model resourceBankIndex tileType =
    ( Tile.hash tileType
    , transform
        [ translate (exitXDistance resourceBankIndex model) -(exitYdistance (tileViewModel model))
        , scale 0.5
        ]
    )


exitXDistance : Int -> Model -> Float
exitXDistance resourceBankIndex model =
    let
        scoreWidth =
            scoreIconSize * 2

        scoreBarWidth =
            model.tileSettings
                |> List.filter Score.collectable
                |> List.length
                |> (*) scoreWidth

        baseOffset =
            (boardWidth (tileViewModel model) - scoreBarWidth) // 2

        offset =
            exitOffsetFunction <| Tile.scale model.context.window
    in
    toFloat (baseOffset + resourceBankIndex * scoreWidth) + offset


exitOffsetFunction : Float -> Float
exitOffsetFunction x =
    25 * (x ^ 2) - (75 * x) + Tile.baseSizeX


exitYdistance : TileViewModel -> Float
exitYdistance model =
    toFloat (boardOffsetTop model) - 9



-- Info Window


renderInfoWindow : Model -> Html Msg
renderInfoWindow { infoWindow, context } =
    InfoWindow.content infoWindow
        |> Maybe.map (renderInfoContent context.successMessageIndex)
        |> Maybe.map (infoContainer infoWindow)
        |> Maybe.withDefault (span [] [])


infoContainer : InfoWindow InfoContent -> Html Msg -> Html Msg
infoContainer infoWindow rendered =
    case InfoWindow.content infoWindow of
        Just RestartAreYouSure ->
            div [ onClick HideInfo ] [ Views.InfoWindow.infoContainer infoWindow rendered ]

        Just ExitAreYouSure ->
            div [ onClick HideInfo ] [ Views.InfoWindow.infoContainer infoWindow rendered ]

        _ ->
            Views.InfoWindow.infoContainer infoWindow rendered


renderInfoContent : Int -> InfoContent -> Html Msg
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
    Dict.get ii successMessages |> Maybe.withDefault "Amazing!"


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


tileViewModel : Model -> TileViewModel
tileViewModel model =
    ( model.context.window
    , model.boardDimensions
    )


topBarViewModel : Model -> TopBarViewModel
topBarViewModel model =
    { window = model.context.window
    , tileSettings = model.tileSettings
    , scores = model.scores
    , remainingMoves = model.remainingMoves
    }


lineViewModel : Model -> LineViewModel
lineViewModel model =
    { window = model.context.window
    , board = model.board
    , boardDimensions = model.boardDimensions
    , isDragging = model.isDragging
    , pointer = model.pointer
    }
