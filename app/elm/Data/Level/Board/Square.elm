module Data.Level.Board.Square exposing (..)

import Data.Level.Move.Type exposing (currentMoveTileType)
import Data.Level.Board.Tile exposing (getTileType, setToDragging)
import Dict
import Data.Level.Types exposing (..)


setAllTilesOfTypeToDragging : Board -> Board
setAllTilesOfTypeToDragging board =
    board
        |> currentMoveTileType
        |> Maybe.map (allTilesOfType board)
        |> Maybe.withDefault board


allTilesOfType : Board -> TileType -> Board
allTilesOfType board tileType =
    board |> Dict.map (setDraggingIfMatch tileType)


setDraggingIfMatch : TileType -> Coord -> Block -> Block
setDraggingIfMatch tileType ( y, x ) block =
    if getTileType block == Just tileType then
        setToDragging (x + 1 + (y * 8)) block
    else
        block
