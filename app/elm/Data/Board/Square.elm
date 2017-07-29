module Data.Board.Square exposing (..)

import Data.Move.Type exposing (currentMoveTileType)
import Data.Tile exposing (getTileType, setToDragging)
import Dict
import Model exposing (..)


handleSquareMove : Model -> Model
handleSquareMove model =
    { model
        | moveShape = Just Square
        , board = setAllTilesOfTypeToDragging model.board
    }


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
