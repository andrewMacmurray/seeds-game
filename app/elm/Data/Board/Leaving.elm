module Data.Board.Leaving exposing (..)

import Data.Tile exposing (setLeavingToEmpty, setToLeaving)
import Helpers.Dict exposing (mapValues)
import Scenes.Level.Model exposing (..)


handleRemoveLeavingTiles : Model -> Model
handleRemoveLeavingTiles model =
    { model | board = model.board |> mapValues setLeavingToEmpty }


handleLeavingTiles : Model -> Model
handleLeavingTiles model =
    { model | board = model.board |> mapValues setToLeaving }
