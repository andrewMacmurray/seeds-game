module Data.Board.Falling exposing (..)

import Data.Tiles exposing (isLeaving, setFallingToStatic, setToFalling)
import Dict
import Helpers.Dict exposing (mapValues)
import Model exposing (..)


handleResetFallingTiles : Model -> Model
handleResetFallingTiles model =
    { model | board = model.board |> mapValues setFallingToStatic }


handleFallingTiles : Model -> Model
handleFallingTiles model =
    { model | board = model.board |> Dict.map (markFallingTile model.board) }


markFallingTile : Board -> Coord -> Block -> Block
markFallingTile board coord block =
    let
        fallingDistance =
            tileFallingDistance ( coord, block ) board
    in
        if fallingDistance > 0 then
            setToFalling fallingDistance block
        else
            block


tileFallingDistance : Move -> Board -> Int
tileFallingDistance ( ( y2, x2 ), _ ) board =
    board
        |> Dict.filter (\( y1, x1 ) block -> x2 == x1 && isLeaving block && y1 > y2)
        |> Dict.size
