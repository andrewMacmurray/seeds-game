module Update exposing (..)

import Data.Board exposing (generateTiles, handleGenerateTiles, handleMakeBoard)
import Dict
import Types exposing (..)


init : ( Model, Cmd Msg )
init =
    initialState ! [ handleGenerateTiles initialState ]


initialState : Model
initialState =
    { board = Dict.empty
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
