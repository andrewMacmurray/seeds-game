module Data.Board.Falling exposing (..)

import Data.Tiles exposing (isLeaving, setToFalling)
import Dict
import Model exposing (..)


handleFallingTiles : Model -> Model
handleFallingTiles model =
    { model | board = markFallingTiles model.board }


markFallingTiles : Board -> Board
markFallingTiles board =
    board |> Dict.map (markFallingTile board)


markFallingTile : Board -> Coord -> TileState -> TileState
markFallingTile board coord tile =
    let
        fallingDistance =
            tileFallingDistance ( coord, tile ) board
    in
        if fallingDistance > 0 then
            setToFalling fallingDistance tile
        else
            tile


tileFallingDistance : Move -> Board -> Int
tileFallingDistance ( ( y2, x2 ), tile2 ) board =
    board
        |> Dict.toList
        |> List.filter (\( ( y1, x1 ), tile1 ) -> x2 == x1 && isLeaving tile1 && y1 > y2)
        |> List.length
