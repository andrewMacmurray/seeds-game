module Update exposing (..)

import Data.Board.Entering exposing (handleAddNewTiles, handleResetEntering, makeNewTiles)
import Data.Board.Falling exposing (handleFallingTiles, handleResetFallingTiles)
import Data.Board.Growing exposing (handleGrowSeedPods, handleResetGrowing, handleSetGrowingSeedPods)
import Data.Board.Leaving exposing (handleLeavingTiles, handleRemoveLeavingTiles)
import Data.Board.Make exposing (handleGenerateTiles, handleMakeBoard)
import Data.Board.Shift exposing (handleShiftBoard, shiftBoard)
import Data.Moves.Check exposing (handleCheckMove, handleStartMove, handleStopMove)
import Data.Moves.Type exposing (currentMoveType)
import Data.Ports exposing (addCssAnimations)
import Delay
import Dict
import Helpers.Animation exposing (bulge, bounces)
import Model exposing (..)


init : ( Model, Cmd Msg )
init =
    initialState ! [ handleGenerateTiles initialState, addCssAnimations <| String.join " " [ bounces, bulge ] ]


initialState : Model
initialState =
    { board = Dict.empty
    , isDragging = False
    , currentMove = []
    , boardSettings = { sizeY = 8, sizeX = 8 }
    , tileSettings = { sizeY = 51, sizeX = 55 }
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        InitTiles tiles ->
            (model |> handleMakeBoard tiles) ! []

        AddTiles tiles ->
            (model |> handleAddNewTiles tiles) ! []

        StopMove ->
            case currentMoveType model.currentMove of
                SeedPod ->
                    model
                        ! [ Delay.start StopMoveSequence
                                [ ( 0, SetGrowingSeedPods )
                                , ( 0, ResetMove )
                                , ( 800, GrowPodsToSeeds )
                                , ( 600, ResetGrowingSeeds )
                                ]
                          ]

                _ ->
                    model
                        ! [ Delay.start StopMoveSequence
                                [ ( 0, SetLeavingTiles )
                                , ( 0, ResetMove )
                                , ( 500, SetFallingTiles )
                                , ( 500, ShiftBoard )
                                , ( 0, MakeNewTiles )
                                , ( 500, ResetEntering )
                                ]
                          ]

        SetLeavingTiles ->
            (model |> handleLeavingTiles) ! []

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

        StopMoveSequence msgs ->
            Delay.handleSequence StopMoveSequence msgs update model

        StartMove move ->
            (model |> handleStartMove move) ! []

        CheckMove move ->
            (model |> handleCheckMove move) ! []
