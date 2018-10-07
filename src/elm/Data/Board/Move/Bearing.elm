module Data.Board.Move.Bearing exposing
    ( addBearings
    , validDirection
    )

import Data.Board.Block exposing (addBearing, moveOrder, setToDragging)
import Data.Board.Moves exposing (lastMove)
import Data.Board.Types exposing (..)
import Dict


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
    moveOrder tileState + 1


isLeft : Coord -> Coord -> Bool
isLeft ( y1, x1 ) ( y2, x2 ) =
    x2 == x1 - 1 && y2 == y1


isRight : Coord -> Coord -> Bool
isRight ( y1, x1 ) ( y2, x2 ) =
    x2 == x1 + 1 && y2 == y1


isAbove : Coord -> Coord -> Bool
isAbove ( y1, x1 ) ( y2, x2 ) =
    x2 == x1 && y2 == y1 - 1


isBelow : Coord -> Coord -> Bool
isBelow ( y1, x1 ) ( y2, x2 ) =
    x2 == x1 && y2 == y1 + 1


directionsToCheck : List (Coord -> Coord -> Bool)
directionsToCheck =
    [ isLeft
    , isRight
    , isAbove
    , isBelow
    ]


check : a -> a -> (a -> a -> Bool) -> Bool
check a b fn =
    fn a b


validDirection : Move -> Move -> Bool
validDirection ( c2, _ ) ( c1, _ ) =
    List.map (check c2 c1) directionsToCheck |> List.any identity
