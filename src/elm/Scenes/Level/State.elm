module Scenes.Level.State exposing (..)

import Config.Scale as ScaleConfig exposing (baseTileSizeX, baseTileSizeY, tileScaleFactor)
import Config.Text exposing (failureMessage, getSuccessMessage, randomSuccessMessageIndex)
import Data.Board.Block exposing (..)
import Data.Board.Falling exposing (..)
import Data.Board.Generate exposing (..)
import Data.Board.Map exposing (..)
import Data.Board.Move.Check exposing (addMoveToBoard, startMove)
import Data.Board.Move.Square exposing (setAllTilesOfTypeToDragging, triggerMoveIfSquare)
import Data.Board.Moves exposing (currentMoveTileType)
import Data.Board.Score exposing (addScoreFromMoves, initialScores, levelComplete)
import Data.Board.Shift exposing (shiftBoard)
import Data.Board.Types exposing (..)
import Data.Board.Wall exposing (addWalls)
import Data.InfoWindow as InfoWindow
import Data.Level.Types exposing (LevelData)
import Dict
import Helpers.Delay exposing (sequenceMs, trigger)
import Helpers.OutMsg exposing (noOutMsg, withOutMsg)
import Scenes.Level.Types exposing (..)
import Task
import Views.Level.Styles exposing (boardHeight, boardOffsetLeft, boardOffsetTop)
import Window exposing (resizes, size)


-- Init


init : Int -> LevelData tutorialConfig -> ( LevelModel, Cmd LevelMsg )
init successMessageIndex levelData =
    let
        model =
            addLevelData levelData <| initialState successMessageIndex
    in
    model
        ! [ handleGenerateTiles levelData model
          , Task.perform WindowSize size
          ]


addLevelData : LevelData tutorialConfig -> LevelModel -> LevelModel
addLevelData { tileSettings, walls, boardDimensions, moves } model =
    { model
        | scores = initialScores tileSettings
        , board = addWalls walls model.board
        , boardDimensions = boardDimensions
        , tileSettings = tileSettings
        , levelStatus = InProgress
        , remainingMoves = moves
    }


initialState : Int -> LevelModel
initialState successMessageIndex =
    { board = Dict.empty
    , scores = Dict.empty
    , isDragging = False
    , remainingMoves = 10
    , moveShape = Nothing
    , tileSettings = []
    , boardDimensions = { y = 8, x = 8 }
    , levelStatus = InProgress
    , successMessageIndex = successMessageIndex
    , infoWindow = InfoWindow.hidden
    , pointerPosition = { y = 0, x = 0 }
    , window = { height = 0, width = 0 }
    }



-- Update


update : LevelMsg -> LevelModel -> ( LevelModel, Cmd LevelMsg, Maybe LevelOutMsg )
update msg model =
    case msg of
        InitTiles walls tiles ->
            noOutMsg
                (model
                    |> handleMakeBoard tiles
                    |> mapBoard (addWalls walls)
                )
                []

        StopMove ->
            case currentMoveTileType model.board of
                Just SeedPod ->
                    noOutMsg model [ growSeedPodsSequence model.moveShape ]

                _ ->
                    noOutMsg model [ removeTilesSequence model.moveShape ]

        SetLeavingTiles ->
            noOutMsg
                (model
                    |> handleAddScore
                    |> mapBlocks setToLeaving
                )
                []

        SetFallingTiles ->
            noOutMsg (mapBoard setFallingTiles model) []

        ShiftBoard ->
            noOutMsg
                (model
                    |> mapBoard shiftBoard
                    |> mapBlocks setFallingToStatic
                    |> mapBlocks setLeavingToEmpty
                )
                []

        SetGrowingSeedPods ->
            noOutMsg (mapBlocks setDraggingToGrowing model) []

        GrowPodsToSeeds ->
            noOutMsg model [ generateRandomSeedType InsertGrowingSeeds model.tileSettings ]

        InsertGrowingSeeds seedType ->
            noOutMsg (handleInsertNewSeeds seedType model) []

        ResetGrowingSeeds ->
            noOutMsg (mapBlocks setGrowingToStatic model) []

        GenerateEnteringTiles ->
            noOutMsg model [ generateEnteringTiles InsertEnteringTiles model.tileSettings model.board ]

        InsertEnteringTiles tiles ->
            noOutMsg (handleInsertEnteringTiles tiles model) []

        ResetEntering ->
            noOutMsg (mapBlocks setEnteringToStatic model) []

        ResetMove ->
            noOutMsg
                (model
                    |> handleResetMove
                    |> handleDecrementRemainingMoves
                )
                []

        StartMove move pointerPosition ->
            noOutMsg (handleStartMove move pointerPosition model) []

        CheckMove position ->
            checkMoveFromPosition position model

        SquareMove ->
            noOutMsg (handleSquareMove model) []

        CheckLevelComplete ->
            handleCheckLevelComplete model

        ShowInfo info ->
            noOutMsg { model | infoWindow = InfoWindow.show info } []

        RemoveInfo ->
            noOutMsg { model | infoWindow = InfoWindow.leave model.infoWindow } []

        InfoHidden ->
            noOutMsg { model | infoWindow = InfoWindow.hidden } []

        LevelWon ->
            -- outMsg signals to parent component that level has been won
            withOutMsg model [] ExitWin

        LevelLost ->
            -- outMsg signals to parent component that level has been lost
            withOutMsg model [] ExitLose

        WindowSize size ->
            noOutMsg { model | window = size } []



-- SEQUENCES


growSeedPodsSequence : Maybe MoveShape -> Cmd LevelMsg
growSeedPodsSequence moveShape =
    sequenceMs
        [ ( initialDelay moveShape, SetGrowingSeedPods )
        , ( 0, ResetMove )
        , ( 800, GrowPodsToSeeds )
        , ( 600, ResetGrowingSeeds )
        ]


removeTilesSequence : Maybe MoveShape -> Cmd LevelMsg
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


winSequence : LevelModel -> Cmd LevelMsg
winSequence model =
    sequenceMs
        [ ( 500, ShowInfo <| getSuccessMessage model.successMessageIndex )
        , ( 2000, RemoveInfo )
        , ( 1000, InfoHidden )
        , ( 0, LevelWon )
        ]


loseSequence : Cmd LevelMsg
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



-- Update Helpers


handleGenerateTiles : LevelData tutorialConfig -> LevelModel -> Cmd LevelMsg
handleGenerateTiles levelData { boardDimensions } =
    generateInitialTiles (InitTiles levelData.walls) levelData.tileSettings boardDimensions


handleMakeBoard : List TileType -> BoardConfig model -> BoardConfig model
handleMakeBoard tileList ({ boardDimensions } as model) =
    { model | board = makeBoard boardDimensions tileList }


handleInsertEnteringTiles : List TileType -> HasBoard model -> HasBoard model
handleInsertEnteringTiles tileList =
    mapBoard <| insertNewEnteringTiles tileList


handleInsertNewSeeds : SeedType -> HasBoard model -> HasBoard model
handleInsertNewSeeds seedType =
    mapBoard <| insertNewSeeds seedType


handleAddScore : LevelModel -> LevelModel
handleAddScore model =
    { model | scores = addScoreFromMoves model.board model.scores }


handleResetMove : LevelModel -> LevelModel
handleResetMove model =
    { model
        | isDragging = False
        , moveShape = Nothing
    }


handleDecrementRemainingMoves : LevelModel -> LevelModel
handleDecrementRemainingMoves model =
    if model.remainingMoves < 1 then
        { model | remainingMoves = 0 }
    else
        { model | remainingMoves = model.remainingMoves - 1 }


handleStartMove : Move -> Position -> LevelModel -> LevelModel
handleStartMove move pointerPosition model =
    { model
        | isDragging = True
        , board = startMove move model.board
        , moveShape = Just Line
        , pointerPosition = pointerPosition
    }


checkMoveFromPosition : Position -> LevelModel -> ( LevelModel, Cmd LevelMsg, Maybe LevelOutMsg )
checkMoveFromPosition position levelModel =
    let
        modelWithPosition =
            { levelModel | pointerPosition = position }
    in
    case moveFromPosition position levelModel of
        Just move ->
            checkMoveWithSquareTrigger move modelWithPosition

        Nothing ->
            noOutMsg modelWithPosition []


checkMoveWithSquareTrigger : Move -> LevelModel -> ( LevelModel, Cmd LevelMsg, Maybe LevelOutMsg )
checkMoveWithSquareTrigger move model =
    let
        newModel =
            model |> handleCheckMove move
    in
    noOutMsg newModel [ triggerMoveIfSquare SquareMove newModel.board ]


handleCheckMove : Move -> LevelModel -> LevelModel
handleCheckMove move model =
    if model.isDragging then
        { model | board = addMoveToBoard move model.board }
    else
        model


moveFromPosition : Position -> LevelModel -> Maybe Move
moveFromPosition position levelModel =
    moveFromCoord levelModel.board <| coordsFromPosition position levelModel


moveFromCoord : Board -> Coord -> Maybe Move
moveFromCoord board coord =
    board |> Dict.get coord |> Maybe.map ((,) coord)


coordsFromPosition : Position -> LevelModel -> Coord
coordsFromPosition position levelModel =
    let
        positionY =
            toFloat <| position.y - boardOffsetTop levelModel

        positionX =
            toFloat <| position.x - boardOffsetLeft levelModel

        scaleFactorY =
            tileScaleFactor levelModel.window * baseTileSizeY

        scaleFactorX =
            tileScaleFactor levelModel.window * baseTileSizeX
    in
    ( floor <| positionY / scaleFactorY
    , floor <| positionX / scaleFactorX
    )


handleSquareMove : LevelModel -> LevelModel
handleSquareMove model =
    { model
        | moveShape = Just Square
        , board = setAllTilesOfTypeToDragging model.board
    }


handleCheckLevelComplete : LevelModel -> ( LevelModel, Cmd LevelMsg, Maybe LevelOutMsg )
handleCheckLevelComplete model =
    if hasWon model then
        noOutMsg { model | levelStatus = Win } [ winSequence model ]
    else if hasLost model then
        noOutMsg { model | levelStatus = Lose } [ loseSequence ]
    else
        noOutMsg model []


hasLost : LevelModel -> Bool
hasLost { remainingMoves, levelStatus } =
    remainingMoves < 1 && levelStatus == InProgress


hasWon : LevelModel -> Bool
hasWon { scores, levelStatus } =
    levelComplete scores && levelStatus == InProgress



-- subscriptions


subscriptions : LevelModel -> Sub LevelMsg
subscriptions _ =
    resizes WindowSize
