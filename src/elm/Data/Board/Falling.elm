module Data.Board.Falling exposing (..)

import Data.Board.Block as Block exposing (Block)
import Data.Board exposing (Board, Coord, Move)
import Dict
import Helpers.Dict exposing (filterValues)
import Data.Board.Shift as Shift


setFallingTiles : Board -> Board
setFallingTiles board =
    let
        beforeBoard =
            board |> Dict.map (temporaryMarkFalling board)

        shiftedBoard =
            beforeBoard |> Shift.shiftBoard

        fallingTilesToUpdate =
            newFallingTiles beforeBoard shiftedBoard
    in
        List.foldl (\( coord, block ) b -> Dict.insert coord block b) beforeBoard fallingTilesToUpdate


newFallingTiles : Board -> Board -> List Move
newFallingTiles beforeBoard shiftedBoard =
    let
        beforeTiles =
            listsOfFallingTiles beforeBoard

        shiftedTiles =
            listsOfFallingTiles shiftedBoard
    in
        List.map2 addFallingDistance beforeTiles shiftedTiles
            |> List.concat


addFallingDistance : List Move -> List Move -> List Move
addFallingDistance before shifted =
    List.map2
        (\( ( y1, x1 ), b ) ( ( y2, x2 ), _ ) -> ( ( y1, x1 ), Block.setToFalling (y2 - y1) b ))
        before
        shifted


listsOfFallingTiles : Board -> List (List Move)
listsOfFallingTiles board =
    board
        |> filterValues Block.isFalling
        |> Shift.groupBoardByColumn
        |> List.map (List.sortBy Shift.yCoord)


temporaryMarkFalling : Board -> Coord -> Block -> Block
temporaryMarkFalling board coord block =
    if shouldMarkFalling board coord then
        Block.setToFalling 0 block
    else
        block


shouldMarkFalling : Board -> Coord -> Bool
shouldMarkFalling board ( y2, x2 ) =
    board
        |> Dict.filter (\( y1, x1 ) b -> x1 == x2 && Block.isLeaving b && y1 > y2)
        |> (not << Dict.isEmpty)
