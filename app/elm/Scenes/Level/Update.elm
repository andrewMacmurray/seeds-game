module Scenes.Level.Update exposing (..)

import Data.Board.Entering exposing (handleAddNewTiles, handleResetEntering, makeNewTiles)
import Data.Board.Falling exposing (handleFallingTiles, handleResetFallingTiles)
import Data.Board.Square exposing (handleSquareMove)
import Data.Board.Growing exposing (handleGrowSeedPods, handleResetGrowing, handleSetGrowingSeedPods)
import Data.Board.Leaving exposing (handleLeavingTiles, handleRemoveLeavingTiles)
import Data.Board.Make exposing (handleGenerateTiles, handleMakeBoard)
import Data.Board.Shift exposing (handleShiftBoard, shiftBoard)
import Data.Move.Check exposing (handleCheckMove, handleStartMove, handleStopMove)
import Data.Move.Square exposing (triggerMoveIfSquare)
import Data.Move.Type exposing (currentMoveTileType)
import Data.Score exposing (handleAddScore, initialScores)
import Data.Sequence exposing (growSeedPodsSequence, removeTilesSequence)
import Delay
import Dict
import Scenes.Level.Model exposing (..)
import Time exposing (millisecond)


initCmd : Cmd Msg
initCmd =
    handleGenerateTiles initialState


initialState : Model
initialState =
    { board = Dict.empty
    , scores = initialScores [ Sun, Rain, Seed ]
    , isDragging = False
    , moveShape = Nothing
    , boardSettings = { sizeY = 8, sizeX = 8 }
    , tileSettings = { sizeY = 51, sizeX = 55 }
    , topBarHeight = 80
    , mouse = { x = 0, y = 0 }
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        InitTiles tiles ->
            (model |> handleMakeBoard tiles) ! []

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
            model ! [ makeNewTiles model.board ]

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

        MousePosition position ->
            { model | mouse = position } ! []


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
