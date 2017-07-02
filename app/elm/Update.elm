module Update exposing (..)

import Data.Board.Entering exposing (handleAddNewTiles, handleResetEntering, makeNewTiles)
import Data.Board.Falling exposing (handleFallingTiles, handleResetFallingTiles)
import Data.Board.Filter exposing (handleSquareMove)
import Data.Board.Growing exposing (handleGrowSeedPods, handleResetGrowing, handleSetGrowingSeedPods)
import Data.Board.Leaving exposing (handleLeavingTiles, handleRemoveLeavingTiles)
import Data.Board.Make exposing (handleGenerateTiles, handleMakeBoard)
import Data.Board.Shift exposing (handleShiftBoard, shiftBoard)
import Data.Moves.Check exposing (handleCheckMove, handleStartMove, handleStopMove, triggerMoveIfSquare)
import Data.Moves.Type exposing (currentMoveType)
import Data.Score exposing (handleAddScore, initialScores)
import Data.Sequence exposing (growSeedPods, removeTiles)
import Delay
import Dict
import Helpers.Window exposing (getWindowSize)
import Model exposing (..)
import Time exposing (millisecond)
import Window exposing (resizes)


init : ( Model, Cmd Msg )
init =
    initialState
        ! [ handleGenerateTiles initialState
          , getWindowSize
          ]


initialState : Model
initialState =
    { board = Dict.empty
    , scores = initialScores [ Sun, Rain, Seed ]
    , isDragging = False
    , moveShape = Nothing
    , boardSettings = { sizeY = 8, sizeX = 8 }
    , tileSettings = { sizeY = 51, sizeX = 55 }
    , topBarHeight = 80
    , window = { height = 0, width = 0 }
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        InitTiles tiles ->
            (model |> handleMakeBoard tiles) ! []

        AddTiles tiles ->
            (model |> handleAddNewTiles tiles) ! []

        StopMove moveType ->
            case currentMoveType model.board of
                Just SeedPod ->
                    model ! [ Delay.sequence growSeedPods ]

                _ ->
                    model ! [ Delay.sequence (removeTiles model moveType) ]

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

        WindowSize size ->
            { model | window = size } ! []


subscriptions : Model -> Sub Msg
subscriptions model =
    resizes WindowSize
