module Data.Board.Leaving exposing (..)

import Data.Moves.Check exposing (coordsList)
import Data.Tiles exposing (setLeavingToEmpty, setToLeaving)
import Dict
import List.Extra exposing (elemIndex)
import Model exposing (..)


handleRemoveLeavingTiles : Model -> Model
handleRemoveLeavingTiles model =
    { model | board = removeLeavingTiles model.board }


handleLeavingTiles : Model -> Model
handleLeavingTiles model =
    let
        newBoard =
            model.board |> setLeavingTiles model.currentMove
    in
        { model | board = newBoard }


removeLeavingTiles : Board -> Board
removeLeavingTiles board =
    board |> Dict.map (\_ tile -> setLeavingToEmpty tile)


setLeavingTiles : List Move -> Board -> Board
setLeavingTiles moves board =
    board |> Dict.map (setTileToLeaving moves)


setTileToLeaving : List Move -> Coord -> TileState -> TileState
setTileToLeaving moves coordToCheck tile =
    case elemIndex coordToCheck (coordsList moves) of
        Just i ->
            setToLeaving i tile

        Nothing ->
            tile
