module Data.Board.Leaving exposing (..)

import Data.Tiles exposing (setLeavingToEmpty, setToLeaving)
import Dict
import Model exposing (..)


handleRemoveLeavingTiles : Model -> Model
handleRemoveLeavingTiles model =
    { model | board = removeLeavingTiles model.board }


handleLeavingTiles : Model -> Model
handleLeavingTiles model =
    { model | board = setLeavingTiles model.board }


removeLeavingTiles : Board -> Board
removeLeavingTiles board =
    board |> Dict.map (\_ tile -> setLeavingToEmpty tile)


setLeavingTiles : Board -> Board
setLeavingTiles board =
    board |> Dict.map (\_ tile -> setToLeaving tile)
