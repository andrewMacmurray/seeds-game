module Data.Level.Move.Square exposing (..)

import Data.Level.Board.Tile exposing (moveOrder)
import Data.Level.Move.Direction exposing (validDirection)
import Data.Level.Move.Utils exposing (currentMoves, emptyMove, moveShape, sameTileType)
import Data.Level.Types exposing (..)
import Delay
import Dict
import Helpers.List exposing (allTrue)
import Scenes.Level.Model exposing (LevelMsg(..))
import Time exposing (millisecond)


triggerMoveIfSquare : Board -> Cmd LevelMsg
triggerMoveIfSquare board =
    if hasSquareTile board then
        Delay.after 0 millisecond SquareMove
    else
        Cmd.none


isValidSquare : Move -> Board -> Bool
isValidSquare first board =
    let
        moves =
            currentMoves board |> List.reverse

        second =
            List.head moves |> Maybe.withDefault emptyMove
    in
        allTrue
            [ moveLongEnough moves
            , validDirection first second
            , sameTileType first second
            , draggingOrderDifferent first second
            ]


draggingOrderDifferent : Move -> Move -> Bool
draggingOrderDifferent ( _, t2 ) ( _, t1 ) =
    moveOrder t2 < (moveOrder t1) - 1


hasSquareTile : Board -> Bool
hasSquareTile board =
    board
        |> Dict.filter (\coord tileState -> moveShape ( coord, tileState ) == Just Square)
        |> (\x -> Dict.size x > 0)


isSquare : List Move -> Bool
isSquare moves =
    moves |> List.any (\a -> moveShape a == Just Square)


moveLongEnough : List Move -> Bool
moveLongEnough moves =
    List.length moves > 3
