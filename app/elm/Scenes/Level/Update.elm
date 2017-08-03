module Scenes.Level.Update exposing (..)

import Data.Board.Block exposing (handleAddWalls)
import Data.Board.Entering exposing (handleAddNewTiles, handleResetEntering, makeNewTiles)
import Data.Board.Falling exposing (handleFallingTiles, handleResetFallingTiles)
import Data.Board.Growing exposing (handleGrowSeedPods, handleResetGrowing, handleSetGrowingSeedPods)
import Data.Board.Leaving exposing (handleLeavingTiles, handleRemoveLeavingTiles)
import Data.Board.Make exposing (handleGenerateTiles, handleMakeBoard)
import Data.Board.Score exposing (handleAddScore, initialScores)
import Data.Board.Sequence exposing (growSeedPodsSequence, removeTilesSequence)
import Data.Board.Shift exposing (handleShiftBoard, shiftBoard)
import Data.Board.Square exposing (handleSquareMove)
import Data.Move.Check exposing (handleCheckMove, handleStartMove, handleStopMove)
import Data.Move.Square exposing (triggerMoveIfSquare)
import Data.Move.Type exposing (currentMoveTileType)
import Delay
import Dict
import Model as Main exposing (LevelData)
import Scenes.Level.Model exposing (..)
import Time exposing (millisecond)


initCmd : LevelData -> Main.Model -> Cmd Main.Msg
initCmd levelData model =
    handleGenerateTiles levelData model.levelModel
        |> Cmd.map Main.LevelMsg


initialState : Model
initialState =
    { board = Dict.empty
    , scores = Dict.empty
    , isDragging = False
    , moveShape = Nothing
    , tileProbabilities = []
    , boardScale = 8
    , tileSize = { y = 51, x = 55 }
    , topBarHeight = 80
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        InitTiles walls tiles ->
            (model
                |> handleMakeBoard tiles
                |> handleAddWalls walls
            )
                ! []

        AddTiles tiles ->
            (model |> handleAddNewTiles tiles) ! []

        StopMove moveType ->
            case currentMoveTileType model.board of
                Just SeedPod ->
                    model ! [ growSeedPodsSequence ]

                _ ->
                    model ! [ removeTilesSequence model moveType ]

        SetLeavingTiles ->
            (model
                |> handleAddScore
                |> handleLeavingTiles
            )
                ! []

        SetFallingTiles ->
            (model |> handleFallingTiles) ! []

        ShiftBoard ->
            (model
                |> handleShiftBoard
                |> handleResetFallingTiles
                |> handleRemoveLeavingTiles
            )
                ! []

        SetGrowingSeedPods ->
            (model |> handleSetGrowingSeedPods) ! []

        GrowPodsToSeeds ->
            (model |> handleGrowSeedPods) ! []

        ResetGrowingSeeds ->
            (model |> handleResetGrowing) ! []

        MakeNewTiles ->
            model ! [ makeNewTiles model ]

        ResetEntering ->
            (model |> handleResetEntering) ! []

        ResetMove ->
            (model |> handleStopMove) ! []

        StartMove move ->
            (model |> handleStartMove move) ! []

        CheckMove move ->
            let
                newModel =
                    model |> handleCheckMove move
            in
                newModel ! [ triggerMoveIfSquare newModel ]

        SquareMove ->
            (model |> handleSquareMove) ! [ Delay.after 600 millisecond <| StopMove Square ]
