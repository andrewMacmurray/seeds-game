module Scenes.Level.State exposing (..)

import Config.Text exposing (failureMessage, getSuccessMessage)
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
import Dict exposing (Dict)
import Helpers.Dict exposing (mapValues)
import Helpers.Effect exposing (sequenceMs, trigger)
import Helpers.OutMsg exposing ((!!!), (!!))
import Scenes.Hub.Types as Main exposing (LevelData, Progress)
import Scenes.Level.Types as Level exposing (..)
import Types exposing (InfoWindow(..))


levelInit : LevelData -> Main.Model -> Cmd Main.Msg
levelInit config model =
    handleGenerateTiles config model.levelModel
        |> Cmd.map Main.LevelMsg


initialState : Level.Model
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


update : Level.Msg -> Level.Model -> ( Level.Model, Cmd Level.Msg, Maybe OutMsg )
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
            { model | levelInfoWindow = removeInfo model.levelInfoWindow } !! []

        InfoHidden ->
            { model | levelInfoWindow = Hidden } !! []

        LevelWon ->
            -- outMsg signals to parent component that level has been won
            { model | successMessageIndex = model.successMessageIndex + 1 } !!! ( [], ExitLevelWithWin )

        LevelLost ->
            -- outMsg signals to parent component that level has been lost
            model !!! ( [], ExitLevelWithLose )



-- SEQUENCES


growSeedPodsSequence : Maybe MoveShape -> Cmd Level.Msg
growSeedPodsSequence moveShape =
    sequenceMs
        [ ( initialDelay moveShape, SetGrowingSeedPods )
        , ( 0, ResetMove )
        , ( 800, GrowPodsToSeeds )
        , ( 600, ResetGrowingSeeds )
        ]


removeTilesSequence : Maybe MoveShape -> Cmd Level.Msg
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


winSequence : Level.Model -> Cmd Level.Msg
winSequence model =
    sequenceMs
        [ ( 500, ShowInfo <| getSuccessMessage model.successMessageIndex )
        , ( 2000, RemoveInfo )
        , ( 1000, InfoHidden )
        , ( 0, LevelWon )
        ]


loseSequence : Cmd Level.Msg
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


removeInfo : InfoWindow String -> InfoWindow String
removeInfo infoWindow =
    case infoWindow of
        Visible info ->
            Hiding info

        window ->
            window


handleGenerateTiles : LevelData -> Level.Model -> Cmd Level.Msg
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


handleAddScore : Level.Model -> Level.Model
handleAddScore model =
    { model | scores = addScoreFromMoves model.board model.scores }


handleResetMove : Level.Model -> Level.Model
handleResetMove model =
    { model
        | isDragging = False
        , moveShape = Nothing
    }


handleDecrementRemainingMoves : Level.Model -> Level.Model
handleDecrementRemainingMoves model =
    if model.remainingMoves < 1 then
        { model | remainingMoves = 0 }
    else
        { model | remainingMoves = model.remainingMoves - 1 }


handleStartMove : Move -> Level.Model -> Level.Model
handleStartMove move model =
    { model
        | isDragging = True
        , board = startMove move model.board
        , moveShape = Just Line
    }


handleCheckMove : Move -> Level.Model -> ( Level.Model, Cmd Level.Msg, Maybe Level.OutMsg )
handleCheckMove move model =
    let
        newModel =
            model |> handleCheckMove_ move
    in
        newModel !! [ triggerMoveIfSquare newModel.board ]


handleCheckMove_ : Move -> Level.Model -> Level.Model
handleCheckMove_ move model =
    if model.isDragging then
        { model | board = addToMove move model.board }
    else
        model


handleSquareMove : Level.Model -> Level.Model
handleSquareMove model =
    { model
        | moveShape = Just Square
        , board = setAllTilesOfTypeToDragging model.board
    }


handleCheckLevelComplete : Level.Model -> ( Level.Model, Cmd Level.Msg, Maybe Level.OutMsg )
handleCheckLevelComplete model =
    if model.remainingMoves < 1 && model.levelStatus == InProgress then
        { model | levelStatus = Lose } !! [ loseSequence ]
    else if levelComplete model.scores && model.levelStatus == InProgress then
        { model | levelStatus = Win } !! [ winSequence model ]
    else
        model !! []
