module Data.Level.Board.Map exposing (..)

import Data.Level.Board.Tile exposing (getTileType, setToDragging)
import Data.Level.Move.Utils exposing (currentMoveTileType)
import Dict
import Helpers.Dict exposing (mapValues)
import Scenes.Level.Types exposing (..)


mapBoard : (Block -> Block) -> HasBoard model -> HasBoard model
mapBoard f model =
    { model | board = (mapValues f) model.board }


transformBoard : (a -> a) -> { m | board : a } -> { m | board : a }
transformBoard fn model =
    { model | board = fn model.board }


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
