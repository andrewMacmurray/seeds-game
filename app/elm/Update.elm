module Update exposing (..)

import Model exposing (..)
import Data.Board.Make exposing (handleGenerateTiles, handleMakeBoard)
import Data.Board.Shift exposing (handleShiftBoard)
import Data.Moves.Check exposing (handleCheckMove, handleStartMove, handleStopMove)
import Dict


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
            (model |> handleShiftBoard |> handleStopMove) ! []

        StartMove move ->
            (model |> handleStartMove move) ! []

        CheckMove move ->
            (model |> handleCheckMove move) ! []
