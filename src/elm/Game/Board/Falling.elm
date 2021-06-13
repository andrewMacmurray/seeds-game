module Game.Board.Falling exposing (setFallingTiles)

import Game.Board as Board exposing (Board)
import Game.Board.Block as Block exposing (Block)
import Game.Board.Coord as Coord exposing (Coord)
import Game.Board.Move as Move exposing (Move)
import Game.Board.Shift as Board


setFallingTiles : Board -> Board
setFallingTiles board =
    let
        beforeBoard =
            Board.update (temporaryMarkFalling board) board

        shiftedBoard =
            Board.shift beforeBoard

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
addFallingDistance move1 move2 =
    let
        c1 =
            Move.coord move1

        c2 =
            Move.coord move2

        fallingDistance =
            Coord.y c2 - Coord.y c1
    in
    Move.block move1
        |> Block.setToFalling fallingDistance
        |> Move.move c1


fallingTiles : Board -> List Move
fallingTiles =
    Board.filterBlocks Block.isFalling
        >> Board.groupBoardByColumn
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
