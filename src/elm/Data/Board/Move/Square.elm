module Data.Board.Move.Square
    exposing
        ( triggerMoveIfSquare
        , hasSquareTile
        , isValidSquare
        , setAllTilesOfTypeToDragging
        )

import Data.Board.Block exposing (getTileType, moveOrder, setToDragging)
import Data.Board.Move.Bearing exposing (validDirection)
import Data.Board.Moves exposing (..)
import Data.Board.Types exposing (..)
import Dict
import Helpers.Effect exposing (trigger)
import List exposing (all)


triggerMoveIfSquare : msg -> Board -> Cmd msg
triggerMoveIfSquare msg board =
    if hasSquareTile board then
        trigger msg
    else
        Cmd.none


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


isValidSquare : Move -> Board -> Bool
isValidSquare first board =
    let
        moves =
            currentMoves board |> List.reverse

        second =
            List.head moves |> Maybe.withDefault emptyMove
    in
        all identity
            [ moveLongEnough moves
            , validDirection first second
            , sameTileType first second
            , draggingOrderDifferent first second
            ]


draggingOrderDifferent : Move -> Move -> Bool
draggingOrderDifferent ( _, b2 ) ( _, b1 ) =
    moveOrder b2 < (moveOrder b1) - 1


hasSquareTile : Board -> Bool
hasSquareTile board =
    board
        |> Dict.filter (\coord block -> moveShape ( coord, block ) == Just Square)
        |> (\x -> Dict.size x > 0)


isSquare : List Move -> Bool
isSquare moves =
    moves |> List.any (\a -> moveShape a == Just Square)


moveLongEnough : List Move -> Bool
moveLongEnough moves =
    List.length moves > 3
