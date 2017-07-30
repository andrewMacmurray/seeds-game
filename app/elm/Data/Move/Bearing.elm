module Data.Move.Bearing exposing (..)

import Data.Move.Direction exposing (..)
import Data.Move.Utils exposing (lastMove)
import Data.Board.Tile exposing (addBearing, moveOrder, setToDragging)
import Dict
import Scenes.Level.Model exposing (..)


addBearings : Move -> Board -> Board
addBearings current board =
    changeBearings current (lastMove board) |> updateMoves board


updateMoves : Board -> ( Move, Move ) -> Board
updateMoves board ( ( c2, t2 ), ( c1, t1 ) ) =
    board
        |> Dict.insert c1 t1
        |> Dict.insert c2 t2


changeBearings : Move -> Move -> ( Move, Move )
changeBearings (( c2, t2 ) as move2) (( c1, t1 ) as move1) =
    let
        newCurrentMove =
            setNewCurrentMove move2 move1
    in
        if isLeft c1 c2 then
            ( newCurrentMove
            , ( c1, addBearing Left t1 )
            )
        else if isRight c1 c2 then
            ( newCurrentMove
            , ( c1, addBearing Right t1 )
            )
        else if isAbove c1 c2 then
            ( newCurrentMove
            , ( c1, addBearing Up t1 )
            )
        else if isBelow c1 c2 then
            ( newCurrentMove
            , ( c1, addBearing Down t1 )
            )
        else
            ( newCurrentMove
            , ( c1, addBearing Head t1 )
            )


setNewCurrentMove : Move -> Move -> Move
setNewCurrentMove ( c2, t2 ) m1 =
    ( c2, setToDragging (incrementMoveOrder m1) t2 )


incrementMoveOrder : Move -> Int
incrementMoveOrder ( _, tileState ) =
    (moveOrder tileState) + 1
