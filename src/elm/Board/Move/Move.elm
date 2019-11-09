module Board.Move.Move exposing (addToBoard)

import Board exposing (Board)
import Board.Block as Block
import Board.Mechanic.Burst as Burst
import Board.Move as Move exposing (Move)
import Board.Move.Bearing as Bearing



-- Add To Board


addToBoard : Move -> Board -> Board
addToBoard curr board =
    if isFirstMove board then
        makeFirstMove curr board

    else if isValidNextMove curr board then
        Bearing.add curr board

    else if shouldUndoMove curr board then
        undoLastMove board

    else
        board


makeFirstMove : Move -> Board -> Board
makeFirstMove move =
    Board.updateAt (Move.coord move) Block.setStaticToFirstMove



-- Undo Last Move


shouldUndoMove : Move -> Board -> Bool
shouldUndoMove curr board =
    Just curr == Board.secondLastMove board


undoLastMove : Board -> Board
undoLastMove board =
    let
        lastCoord =
            Move.coord <| Board.lastMove board

        newBoard =
            Board.updateAt lastCoord Block.setDraggingToStatic board
    in
    board
        |> Board.secondLastMove
        |> Maybe.map (\m -> Board.updateAt (Move.coord m) Block.clearBearing newBoard)
        |> Maybe.withDefault newBoard



-- Valid Moves


isValidNextMove : Move -> Board -> Bool
isValidNextMove move board =
    isValidStandardMove move board || Burst.isValidNextMove move board


isValidStandardMove : Move -> Board -> Bool
isValidStandardMove curr board =
    let
        last =
            Board.lastMove board

        inCurrentMoves =
            Board.isActiveMove curr board
    in
    Move.areNeighbours curr last
        && Move.sameTileType curr last
        && not inCurrentMoves



-- Helpers


isFirstMove : Board -> Bool
isFirstMove =
    Board.activeMoves >> List.length >> (==) 0
