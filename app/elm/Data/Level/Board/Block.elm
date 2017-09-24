module Data.Level.Board.Block exposing (..)

import Dict
import Scenes.Level.Model exposing (..)


addWalls : List Coord -> Board -> Board
addWalls coords board =
    List.foldl (\coords currentBoard -> Dict.update coords (Maybe.map (always Wall)) currentBoard) board coords


getTileState : Block -> TileState
getTileState =
    fold identity Empty


map : (TileState -> TileState) -> Block -> Block
map fn block =
    case block of
        Wall ->
            Wall

        Space tileState ->
            Space <| fn tileState


fold : (TileState -> a) -> a -> Block -> a
fold fn default block =
    case block of
        Wall ->
            default

        Space tileState ->
            fn tileState
