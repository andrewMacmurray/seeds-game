module Data.Move.Square exposing (..)

import Data.Move.Direction exposing (validDirection)
import Data.Move.Type exposing (emptyMove, moveShape, sameTileType)
import Data.Move.Utils exposing (currentMoves)
import Data.Board.Tile exposing (moveOrder)
import Delay
import Dict
import Scenes.Level.Model exposing (..)
import Time exposing (millisecond)
import Helpers.List exposing (allTrue)


triggerMoveIfSquare : Model -> Cmd Msg
triggerMoveIfSquare model =
    if hasSquareTile model.board then
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
