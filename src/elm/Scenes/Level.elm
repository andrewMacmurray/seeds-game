module Scenes.Level exposing
    ( Model
    , Msg
    , Status(..)
    , init
    , update
    , view
    )

import Browser.Events
import Config.Scale as ScaleConfig exposing (baseTileSizeX, baseTileSizeY, tileScaleFactor)
import Config.Text exposing (failureMessage, getSuccessMessage)
import Css.Color exposing (Color)
import Css.Style as Style exposing (..)
import Css.Transform exposing (scale, translate)
import Css.Transition exposing (delay, transitionAll)
import Data.Board.Block exposing (..)
import Data.Board.Falling exposing (..)
import Data.Board.Generate exposing (..)
import Data.Board.Map exposing (..)
import Data.Board.Move.Check exposing (addMoveToBoard, startMove)
import Data.Board.Move.Square exposing (setAllTilesOfTypeToDragging, triggerMoveIfSquare)
import Data.Board.Moves exposing (currentMoveTileType)
import Data.Board.Score as Score exposing (addScoreFromMoves, initialScores, levelComplete, scoreTileTypes)
import Data.Board.Shift exposing (shiftBoard)
import Data.Board.Tile as Tile
import Data.Board.Types exposing (..)
import Data.Board.Wall exposing (addWalls)
import Data.InfoWindow as InfoWindow exposing (InfoWindow)
import Data.Level.Types exposing (LevelData, TileSetting)
import Data.Pointer exposing (Pointer, onPointerDown, onPointerMove, onPointerUp)
import Dict
import Exit exposing (continue, exitWith)
import Helpers.Delay exposing (sequence, trigger)
import Helpers.Html exposing (emptyProperty)
import Html exposing (Attribute, Html, div, span, text)
import Html.Attributes exposing (attribute, class)
import Shared exposing (Window)
import Task
import Views.Backdrop exposing (backdrop)
import Views.InfoWindow exposing (infoContainer)
import Views.Level.Line exposing (renderLine)
import Views.Level.LineDrag exposing (LineViewModel, handleLineDrag)
import Views.Level.Styles exposing (..)
import Views.Level.Tile exposing (renderTile_)
import Views.Level.TopBar exposing (TopBarViewModel, remainingMoves, topBar)



-- MODEL


type alias Model =
    { shared : Shared.Data
    , board : Board
    , scores : Scores
    , isDragging : Bool
    , remainingMoves : Int
    , moveShape : Maybe MoveShape
    , tileSettings : List TileSetting
    , boardDimensions : BoardDimensions
    , levelStatus : Status
    , infoWindow : InfoWindow String
    , pointer : Pointer
    }


type Msg
    = InitTiles (List ( Color, Coord )) (List TileType)
    | SquareMove
    | StopMove
    | StartMove Move Pointer
    | CheckMove Pointer
    | SetLeavingTiles
    | SetFallingTiles
    | SetGrowingSeedPods
    | GrowPodsToSeeds
    | InsertGrowingSeeds SeedType
    | ResetGrowingSeeds
    | GenerateEnteringTiles
    | InsertEnteringTiles (List TileType)
    | ResetEntering
    | ShiftBoard
    | ResetMove
    | CheckLevelComplete
    | ShowInfo String
    | RemoveInfo
    | InfoHidden
    | LevelWon
    | LevelLost


type Status
    = InProgress
    | Lose
    | Win



-- INIT


init : LevelData tutorialConfig -> Shared.Data -> ( Model, Cmd Msg )
init levelData shared =
    let
        model =
            addLevelData levelData <| initialState shared
    in
    ( model
    , handleGenerateTiles levelData model
    )


addLevelData : LevelData tutorialConfig -> Model -> Model
addLevelData { tileSettings, walls, boardDimensions, moves } model =
    { model
        | scores = initialScores tileSettings
        , board = addWalls walls model.board
        , boardDimensions = boardDimensions
        , tileSettings = tileSettings
        , levelStatus = InProgress
        , remainingMoves = moves
    }


initialState : Shared.Data -> Model
initialState shared =
    { shared = shared
    , board = Dict.empty
    , scores = Dict.empty
    , isDragging = False
    , remainingMoves = 10
    , moveShape = Nothing
    , tileSettings = []
    , boardDimensions = { y = 8, x = 8 }
    , levelStatus = InProgress
    , infoWindow = InfoWindow.hidden
    , pointer = { y = 0, x = 0 }
    }



-- UPDATE


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
            case currentMoveTileType model.board of
                Just SeedPod ->
                    continue model [ growSeedPodsSequence model.moveShape ]

                _ ->
                    continue model [ removeTilesSequence model.moveShape ]

        SetLeavingTiles ->
            continue
                (model
                    |> handleAddScore
                    |> mapBlocks setToLeaving
                )
                []

        SetFallingTiles ->
            continue (mapBoard setFallingTiles model) []

        ShiftBoard ->
            continue
                (model
                    |> mapBoard shiftBoard
                    |> mapBlocks setFallingToStatic
                    |> mapBlocks setLeavingToEmpty
                )
                []

        SetGrowingSeedPods ->
            continue (mapBlocks setDraggingToGrowing model) []

        GrowPodsToSeeds ->
            continue model [ generateRandomSeedType InsertGrowingSeeds model.tileSettings ]

        InsertGrowingSeeds seedType ->
            continue (handleInsertNewSeeds seedType model) []

        ResetGrowingSeeds ->
            continue (mapBlocks setGrowingToStatic model) []

        GenerateEnteringTiles ->
            continue model [ generateEnteringTiles InsertEnteringTiles model.tileSettings model.board ]

        InsertEnteringTiles tiles ->
            continue (handleInsertEnteringTiles tiles model) []

        ResetEntering ->
            continue (mapBlocks setEnteringToStatic model) []

        ResetMove ->
            continue
                (model
                    |> handleResetMove
                    |> handleDecrementRemainingMoves
                )
                []

        StartMove move pointer ->
            continue (handleStartMove move pointer model) []

        CheckMove pointer ->
            checkMoveFromPosition pointer model

        SquareMove ->
            continue (handleSquareMove model) []

        CheckLevelComplete ->
            handleCheckLevelComplete model

        ShowInfo info ->
            continue { model | infoWindow = InfoWindow.visible info } []

        RemoveInfo ->
            continue { model | infoWindow = InfoWindow.leaving model.infoWindow } []

        InfoHidden ->
            continue { model | infoWindow = InfoWindow.hidden } []

        LevelWon ->
            exitWith Win model []

        LevelLost ->
            exitWith Lose model []



-- SEQUENCES


growSeedPodsSequence : Maybe MoveShape -> Cmd Msg
growSeedPodsSequence moveShape =
    sequence
        [ ( initialDelay moveShape, SetGrowingSeedPods )
        , ( 0, ResetMove )
        , ( 800, GrowPodsToSeeds )
        , ( 0, CheckLevelComplete )
        , ( 600, ResetGrowingSeeds )
        ]


removeTilesSequence : Maybe MoveShape -> Cmd Msg
removeTilesSequence moveShape =
    sequence
        [ ( initialDelay moveShape, SetLeavingTiles )
        , ( 0, ResetMove )
        , ( fallDelay moveShape, SetFallingTiles )
        , ( 500, ShiftBoard )
        , ( 0, CheckLevelComplete )
        , ( 0, GenerateEnteringTiles )
        , ( 500, ResetEntering )
        ]


winSequence : Model -> Cmd Msg
winSequence model =
    sequence
        [ ( 500, ShowInfo <| getSuccessMessage model.shared.successMessageIndex )
        , ( 2000, RemoveInfo )
        , ( 1000, InfoHidden )
        , ( 0, LevelWon )
        ]


loseSequence : Cmd Msg
loseSequence =
    sequence
        [ ( 500, ShowInfo failureMessage )
        , ( 2000, RemoveInfo )
        , ( 1000, InfoHidden )
        , ( 0, LevelLost )
        ]


initialDelay : Maybe MoveShape -> Float
initialDelay moveShape =
    if moveShape == Just Square then
        200

    else
        0


fallDelay : Maybe MoveShape -> Float
fallDelay moveShape =
    if moveShape == Just Square then
        500

    else
        350



-- UPDATE Helpers


type alias HasBoard model =
    { model | board : Board, boardDimensions : BoardDimensions }


handleGenerateTiles : LevelData tutorialConfig -> Model -> Cmd Msg
handleGenerateTiles levelData { boardDimensions } =
    generateInitialTiles (InitTiles levelData.walls) levelData.tileSettings boardDimensions


handleMakeBoard : List TileType -> HasBoard model -> HasBoard model
handleMakeBoard tileList ({ boardDimensions } as model) =
    { model | board = makeBoard boardDimensions tileList }


handleInsertEnteringTiles : List TileType -> HasBoard model -> HasBoard model
handleInsertEnteringTiles tileList =
    mapBoard <| insertNewEnteringTiles tileList


handleInsertNewSeeds : SeedType -> HasBoard model -> HasBoard model
handleInsertNewSeeds seedType =
    mapBoard <| insertNewSeeds seedType


handleAddScore : Model -> Model
handleAddScore model =
    { model | scores = addScoreFromMoves model.board model.scores }


handleResetMove : Model -> Model
handleResetMove model =
    { model
        | isDragging = False
        , moveShape = Nothing
    }


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
        , moveShape = Just Line
        , pointer = pointer
    }


checkMoveFromPosition : Pointer -> Model -> Exit.With Status ( Model, Cmd Msg )
checkMoveFromPosition pointer model =
    case moveFromPosition pointer model of
        Just move ->
            checkMoveWithSquareTrigger move { model | pointer = pointer }

        Nothing ->
            continue { model | pointer = pointer } []


checkMoveWithSquareTrigger : Move -> Model -> Exit.With Status ( Model, Cmd Msg )
checkMoveWithSquareTrigger move model =
    let
        newModel =
            model |> handleCheckMove move
    in
    continue newModel [ triggerMoveIfSquare SquareMove newModel.board ]


handleCheckMove : Move -> Model -> Model
handleCheckMove move model =
    if model.isDragging then
        { model | board = addMoveToBoard move model.board }

    else
        model


moveFromPosition : Pointer -> Model -> Maybe Move
moveFromPosition pointer model =
    moveFromCoord model.board <| coordsFromPosition pointer model


moveFromCoord : Board -> Coord -> Maybe Move
moveFromCoord board coord =
    board |> Dict.get coord |> Maybe.map (\b -> ( coord, b ))


coordsFromPosition : Pointer -> Model -> Coord
coordsFromPosition pointer model =
    let
        vm =
            ( model.shared.window, model.boardDimensions )

        positionY =
            toFloat <| pointer.y - boardOffsetTop vm

        positionX =
            toFloat <| pointer.x - boardOffsetLeft vm

        scaleFactorY =
            tileScaleFactor model.shared.window * baseTileSizeY

        scaleFactorX =
            tileScaleFactor model.shared.window * baseTileSizeX
    in
    ( floor <| positionY / scaleFactorY
    , floor <| positionX / scaleFactorX
    )


handleSquareMove : Model -> Model
handleSquareMove model =
    { model
        | moveShape = Just Square
        , board = setAllTilesOfTypeToDragging model.board
    }


handleCheckLevelComplete : Model -> Exit.With Status ( Model, Cmd Msg )
handleCheckLevelComplete model =
    if hasWon model then
        continue { model | levelStatus = Win } [ winSequence model ]

    else if hasLost model then
        continue { model | levelStatus = Lose } [ loseSequence ]

    else
        continue model []


hasLost : Model -> Bool
hasLost { remainingMoves, levelStatus } =
    remainingMoves < 1 && levelStatus == InProgress


hasWon : Model -> Bool
hasWon { scores, levelStatus } =
    levelComplete scores && levelStatus == InProgress



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
        , renderBoard model
        , handleLineDrag <| lineViewModel model
        , div [ class "w-100 h-100 fixed z-1 top-0" ] [ backdrop ]
        ]


handleStop : Model -> Attribute Msg
handleStop model =
    applyIf model.isDragging <| onPointerUp StopMove


handleCheck : Model -> Attribute Msg
handleCheck model =
    applyIf model.isDragging <| onPointerMove CheckMove


disableIfComplete : Model -> Attribute msg
disableIfComplete model =
    applyIf (not <| model.levelStatus == InProgress) <| class "touch-disabled"


applyIf : Bool -> Attribute msg -> Attribute msg
applyIf predicate attr =
    if predicate then
        attr

    else
        emptyProperty


renderBoard : Model -> Html Msg
renderBoard model =
    boardLayout model
        [ div [ class "relative z-5" ] <| renderTiles model
        , div [ class "absolute top-0 left-0 z-0" ] <| renderLines model
        ]


renderTiles : Model -> List (Html Msg)
renderTiles model =
    model.board
        |> Dict.toList
        |> List.map (renderTile model)


renderTile : Model -> Move -> Html Msg
renderTile model (( ( y, x ) as coord, tile ) as move) =
    div
        [ hanldeMoveEvents model move
        , class "pointer"
        , attribute "touch-action" "none"
        ]
        [ renderTile_ (leavingStyles model move) model.shared.window model.moveShape move ]


renderLines : Model -> List (Html msg)
renderLines model =
    model.board
        |> Dict.toList
        |> List.map (renderLine model.shared.window)


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
    applyIf (not model.isDragging) <| onPointerDown <| StartMove move


renderInfoWindow : Model -> Html msg
renderInfoWindow { infoWindow } =
    let
        infoContent =
            InfoWindow.content infoWindow |> Maybe.withDefault ""
    in
    case InfoWindow.state infoWindow of
        InfoWindow.Hidden ->
            span [] []

        _ ->
            infoContainer infoWindow <|
                div [ class "pv5 f3 tracked-mega" ] [ text infoContent ]


leavingStyles : Model -> Move -> List Style
leavingStyles model (( _, tile ) as move) =
    if isLeaving tile then
        [ transitionAll 800 [ delay <| modBy 5 (leavingOrder tile) * 80 ]
        , opacity 0.2
        , handleExitDirection move model
        ]

    else
        []


handleExitDirection : Move -> Model -> Style
handleExitDirection ( coord, block ) model =
    case getTileState block of
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
        |> Maybe.withDefault empty


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
            ScaleConfig.scoreIconSize * 2

        scoreBarWidth =
            model.tileSettings
                |> List.filter Score.collectable
                |> List.length
                |> (*) scoreWidth

        baseOffset =
            (boardWidth (tileViewModel model) - scoreBarWidth) // 2

        offset =
            exitOffsetFunction <| ScaleConfig.tileScaleFactor model.shared.window
    in
    toFloat (baseOffset + resourceBankIndex * scoreWidth) + offset


exitOffsetFunction : Float -> Float
exitOffsetFunction x =
    25 * (x ^ 2) - (75 * x) + ScaleConfig.baseTileSizeX


exitYdistance : TileViewModel -> Float
exitYdistance model =
    toFloat (boardOffsetTop model) - 9



-- VIEW MODELS


tileViewModel : Model -> TileViewModel
tileViewModel model =
    ( model.shared.window
    , model.boardDimensions
    )


topBarViewModel : Model -> TopBarViewModel
topBarViewModel model =
    { window = model.shared.window
    , tileSettings = model.tileSettings
    , scores = model.scores
    , remainingMoves = model.remainingMoves
    }


lineViewModel : Model -> LineViewModel
lineViewModel model =
    { window = model.shared.window
    , board = model.board
    , boardDimensions = model.boardDimensions
    , isDragging = model.isDragging
    , pointer = model.pointer
    }
