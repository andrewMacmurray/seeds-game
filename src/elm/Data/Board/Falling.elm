module Data.Board.Falling exposing (setFallingTiles)

import Data.Board as Board
import Data.Board.Block as Block
import Data.Board.Coord as Coord
import Data.Board.Move as Move
import Data.Board.Shift as Shift
import Data.Board.Types exposing (..)
import Helpers.Dict exposing (filterValues)


setFallingTiles : Board -> Board
setFallingTiles board =
    let
        beforeBoard =
            Board.update (temporaryMarkFalling board) board

        shiftedBoard =
            Shift.shiftBoard beforeBoard

        fallingTilesToUpdate =
            newFallingTiles beforeBoard shiftedBoard
    in
    List.foldl Board.place beforeBoard fallingTilesToUpdate


newFallingTiles : Board -> Board -> List Move
newFallingTiles beforeBoard shiftedBoard =
    let
        beforeTiles =
            fallingTiles beforeBoard

        shiftedTiles =
            fallingTiles shiftedBoard
    in
    List.map2 addFallingDistance beforeTiles shiftedTiles


addFallingDistance : Move -> Move -> Move
addFallingDistance ( c1, b ) ( c2, _ ) =
    ( c1
    , Block.setToFalling (Coord.y c2 - Coord.y c1) b
    )


fallingTiles : Board -> List Move
fallingTiles =
    filterValues Block.isFalling
        >> Shift.groupBoardByColumn
        >> List.map (List.sortBy Move.y)
        >> List.concat


temporaryMarkFalling : Board -> Coord -> Block -> Block
temporaryMarkFalling board coord block =
    if shouldMarkFalling board coord then
        Block.setToFalling 0 block

    else
        block


shouldMarkFalling : Board -> Coord -> Bool
shouldMarkFalling board c2 =
    let
        shouldFall c1 block =
            Coord.x c1 == Coord.x c2 && Block.isLeaving block && Coord.y c1 > Coord.y c2
    in
    board
        |> Board.filter shouldFall
        |> (not << Board.isEmpty)
