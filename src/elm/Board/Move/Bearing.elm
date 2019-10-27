module Board.Move.Bearing exposing (add)

import Board exposing (Board)
import Board.Block as Block
import Board.Coord as Coord
import Board.Move as Move exposing (Move)
import Board.Tile exposing (Bearing(..))


add : Move -> Board -> Board
add current board =
    Board.lastMove board
        |> changeBearings current
        |> updateMoves board


updateMoves : Board -> ( Move, Move ) -> Board
updateMoves board ( move2, move1 ) =
    board
        |> Board.place move1
        |> Board.place move2


changeBearings : Move -> Move -> ( Move, Move )
changeBearings move2 move1 =
    let
        c1 =
            Move.coord move1

        c2 =
            Move.coord move2

        withBearing bearing =
            ( setNewCurrentMove move1 move2
            , Move.move c1 <| Block.addBearing bearing <| Move.block move1
            )
    in
    if Coord.isLeft c1 c2 then
        withBearing Left

    else if Coord.isRight c1 c2 then
        withBearing Right

    else if Coord.isAbove c1 c2 then
        withBearing Up

    else if Coord.isBelow c1 c2 then
        withBearing Down

    else
        withBearing Head


setNewCurrentMove : Move -> Move -> Move
setNewCurrentMove move1 =
    Move.updateBlock (Block.setToDragging <| incrementMoveOrder move1)


incrementMoveOrder : Move -> Int
incrementMoveOrder move =
    Block.moveOrder (Move.block move) + 1