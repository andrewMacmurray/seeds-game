module Data.Board.Filter exposing (..)

import Data.Moves.Type exposing (currentMoveTileType)
import Data.Tiles exposing (getTileType, setToDragging)
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


setDraggingIfMatch : TileType -> Coord -> TileState -> TileState
setDraggingIfMatch tileType ( y, x ) tileState =
    if getTileType tileState == Just tileType then
        setToDragging (x + 1 + (y * 8)) tileState
    else
        tileState
