module Update exposing (..)

import Data.Board exposing (generateTiles, handleGenerateTiles, handleMakeBoard)
import Data.Move exposing (addToMove, handleCheckMove, handleStartMove, handleStopMove)
import Dict
import Model exposing (..)


init : ( Model, Cmd Msg )
init =
    initialState ! [ handleGenerateTiles initialState ]


initialState : Model
initialState =
    { board = Dict.empty
    , isDragging = False
    , currentMove = Nothing
    , boardSettings =
        { sizeY = 8
        , sizeX = 8
        }
    , tileSettings =
        { sizeY = 47
        , sizeX = 52
        }
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RandomTiles tiles ->
            (model |> handleMakeBoard tiles) ! []

        StopMove ->
            (handleStopMove model) ! []

        StartMove move ->
            (model |> handleStartMove move) ! []

        CheckMove move ->
            (model |> handleCheckMove move) ! []
