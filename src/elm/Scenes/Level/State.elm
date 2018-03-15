module Scenes.Level.State exposing (..)

import Config.Text exposing (failureMessage, getSuccessMessage)
import Data.InfoWindow as InfoWindow exposing (InfoWindow(..))
import Data.Level.Board.Block exposing (addWalls)
import Data.Level.Board.Falling exposing (setFallingTiles)
import Data.Level.Board.Generate exposing (..)
import Data.Level.Board.Map exposing (mapBoard, setAllTilesOfTypeToDragging, transformBoard)
import Data.Level.Board.Shift exposing (shiftBoard)
import Data.Level.Board.Tile exposing (..)
import Data.Level.Move.Check exposing (addToMove, startMove)
import Data.Level.Move.Square exposing (triggerMoveIfSquare)
import Data.Level.Move.Utils exposing (currentMoveTileType)
import Data.Level.Score exposing (addScoreFromMoves, initialScores, levelComplete)
import Dict
import Helpers.Dict exposing (mapValues)
import Helpers.Effect exposing (sequenceMs, trigger)
import Helpers.OutMsg exposing ((!!), (!!!))
import Scenes.Hub.Types exposing (LevelData)
import Scenes.Level.Types exposing (..)


init : LevelData -> Model -> ( Model, Cmd Msg )
init levelData model =
    addLevelData levelData model |> generateTiles levelData


generateTiles : LevelData -> Model -> ( Model, Cmd Msg )
generateTiles levelData model =
    model ! [ handleGenerateTiles levelData model ]


addLevelData : LevelData -> Model -> Model
addLevelData { tileSettings, walls, boardDimensions, moves } model =
    { model
        | scores = initialScores tileSettings
        , board = addWalls walls model.board
        , boardDimensions = boardDimensions
        , tileSettings = tileSettings
        , levelStatus = InProgress
        , remainingMoves = moves
    }


initialState : Model
initialState =
    { board = Dict.empty
    , scores = Dict.empty
    , isDragging = False
    , remainingMoves = 10
    , moveShape = Nothing
    , tileSettings = []
    , boardDimensions = { y = 8, x = 8 }
    , levelStatus = InProgress
    , successMessageIndex = 0
    , levelInfoWindow = Hidden
    , mouse = { y = 0, x = 0 }
    , window = { height = 0, width = 0 }
    }


update : Msg -> Model -> ( Model, Cmd Msg, Maybe OutMsg )
update msg model =
    case msg of
        InitTiles walls tiles ->
            (model
                |> handleMakeBoard tiles
                |> transformBoard (addWalls walls)
            )
                !! []

        StopMove ->
            case currentMoveTileType model.board of
                Just SeedPod ->
                    model !! [ growSeedPodsSequence model.moveShape ]

                _ ->
                    model !! [ removeTilesSequence model.moveShape ]

        SetLeavingTiles ->
            (model
                |> handleAddScore
                |> mapBoard setToLeaving
            )
                !! []

        SetFallingTiles ->
            transformBoard setFallingTiles model !! []

        ShiftBoard ->
            (model
                |> transformBoard shiftBoard
                |> mapBoard setFallingToStatic
                |> mapBoard setLeavingToEmpty
            )
                !! []

        SetGrowingSeedPods ->
            mapBoard setDraggingToGrowing model !! []

        GrowPodsToSeeds ->
            model !! [ generateRandomSeedType model.tileSettings ]

        InsertGrowingSeeds seedType ->
            handleInsertNewSeeds seedType model !! []

        ResetGrowingSeeds ->
            mapBoard setGrowingToStatic model !! []

        GenerateEnteringTiles ->
            model !! [ generateEnteringTiles model.tileSettings model.board ]

        InsertEnteringTiles tiles ->
            handleInsertEnteringTiles tiles model !! []

        ResetEntering ->
            transformBoard (mapValues setEnteringToStatic) model !! []

        ResetMove ->
            (model
                |> handleResetMove
                |> handleDecrementRemainingMoves
            )
                !! []

        StartMove move ->
            handleStartMove move model !! []

        CheckMove move ->
            handleCheckMove move model

        SquareMove ->
            handleSquareMove model !! []

        CheckLevelComplete ->
            handleCheckLevelComplete model

        RandomSuccessMessageIndex i ->
            { model | successMessageIndex = i } !! []

        ShowInfo info ->
            { model | levelInfoWindow = Visible info } !! []

        RemoveInfo ->
            { model | levelInfoWindow = InfoWindow.toHiding model.levelInfoWindow } !! []

        InfoHidden ->
            { model | levelInfoWindow = Hidden } !! []

        LevelWon ->
            -- outMsg signals to parent component that level has been won
            { model | successMessageIndex = model.successMessageIndex + 1 } !!! ( [], ExitLevelWithWin )

        LevelLost ->
            -- outMsg signals to parent component that level has been lost
            model !!! ( [], ExitLevelWithLose )



-- SEQUENCES


growSeedPodsSequence : Maybe MoveShape -> Cmd Msg
growSeedPodsSequence moveShape =
    sequenceMs
        [ ( initialDelay moveShape, SetGrowingSeedPods )
        , ( 0, ResetMove )
        , ( 800, GrowPodsToSeeds )
        , ( 600, ResetGrowingSeeds )
        ]


removeTilesSequence : Maybe MoveShape -> Cmd Msg
removeTilesSequence moveShape =
    sequenceMs
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
    sequenceMs
        [ ( 500, ShowInfo <| getSuccessMessage model.successMessageIndex )
        , ( 2000, RemoveInfo )
        , ( 1000, InfoHidden )
        , ( 0, LevelWon )
        ]


loseSequence : Cmd Msg
loseSequence =
    sequenceMs
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



-- UPDATE HELPERS


handleGenerateTiles : LevelData -> Model -> Cmd Msg
handleGenerateTiles levelData { boardDimensions } =
    generateInitialTiles levelData boardDimensions


handleMakeBoard : List TileType -> BoardConfig model -> BoardConfig model
handleMakeBoard tileList ({ boardDimensions } as model) =
    { model | board = makeBoard boardDimensions tileList }


handleInsertEnteringTiles : List TileType -> HasBoard model -> HasBoard model
handleInsertEnteringTiles tileList =
    transformBoard <| insertNewEnteringTiles tileList


handleInsertNewSeeds : SeedType -> HasBoard model -> HasBoard model
handleInsertNewSeeds seedType =
    transformBoard <| insertNewSeeds seedType


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


handleStartMove : Move -> Model -> Model
handleStartMove move model =
    { model
        | isDragging = True
        , board = startMove move model.board
        , moveShape = Just Line
    }


handleCheckMove : Move -> Model -> ( Model, Cmd Msg, Maybe OutMsg )
handleCheckMove move model =
    let
        newModel =
            model |> handleCheckMove_ move
    in
        newModel !! [ triggerMoveIfSquare newModel.board ]


handleCheckMove_ : Move -> Model -> Model
handleCheckMove_ move model =
    if model.isDragging then
        { model | board = addToMove move model.board }
    else
        model


handleSquareMove : Model -> Model
handleSquareMove model =
    { model
        | moveShape = Just Square
        , board = setAllTilesOfTypeToDragging model.board
    }


handleCheckLevelComplete : Model -> ( Model, Cmd Msg, Maybe OutMsg )
handleCheckLevelComplete model =
    if hasLost model then
        { model | levelStatus = Lose } !! [ loseSequence ]
    else if hasWon model then
        { model | levelStatus = Win } !! [ winSequence model ]
    else
        model !! []


hasLost : Model -> Bool
hasLost { remainingMoves, levelStatus } =
    remainingMoves < 1 && levelStatus == InProgress


hasWon : Model -> Bool
hasWon { scores, levelStatus } =
    levelComplete scores && levelStatus == InProgress
