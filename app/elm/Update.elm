module Update exposing (..)

import Data.Board.Falling exposing (handleFallingTiles)
import Data.Board.Leaving exposing (handleLeavingTiles, handleRemoveLeavingTiles)
import Data.Board.Make exposing (handleGenerateTiles, handleMakeBoard)
import Data.Board.Shift exposing (handleShiftBoard, shiftBoard)
import Data.Moves.Check exposing (handleCheckMove, handleStartMove, handleStopMove)
import Delay
import Dict
import Model exposing (..)


init : ( Model, Cmd Msg )
init =
    initialState ! [ handleGenerateTiles initialState ]


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
        RandomTiles tiles ->
            (model |> handleMakeBoard tiles) ! []

        StopMove ->
            model
                ! [ Delay.start StopMoveSequence
                        [ ( 0, SetLeavingTiles )
                        , ( 500, SetFallingTiles )
                        , ( 500, ShiftBoard )
                        , ( 500, ResetMove )
                        ]
                  ]

        SetLeavingTiles ->
            (model |> handleLeavingTiles) ! []

        SetFallingTiles ->
            (model |> handleFallingTiles) ! []

        ShiftBoard ->
            (model |> handleRemoveLeavingTiles |> handleShiftBoard) ! []

        ResetMove ->
            (model |> handleStopMove) ! []

        StopMoveSequence msgs ->
            Delay.handleSequence StopMoveSequence msgs update model

        StartMove move ->
            (model |> handleStartMove move) ! []

        CheckMove move ->
            (model |> handleCheckMove move) ! []
