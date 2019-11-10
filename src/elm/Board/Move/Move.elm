module Board.Move.Move exposing (drag)

import Board exposing (Board)
import Board.Block as Block
import Board.Mechanic.Burst as Burst
import Board.Mechanic.Pod as Pod
import Board.Move as Check exposing (Move)
import Board.Move.Bearing as Bearing
import Board.Move.Check as Check



-- Drag


drag : Move -> Board -> Board
drag curr board =
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
    Board.updateAt (Check.coord move) Block.setStaticToFirstMove



-- Undo Last Move


shouldUndoMove : Move -> Board -> Bool
shouldUndoMove curr board =
    Just curr == Board.secondLastMove board


undoLastMove : Board -> Board
undoLastMove board =
    let
        lastCoord =
            Check.coord <| Board.lastMove board

        newBoard =
            Board.updateAt lastCoord Block.setDraggingToStatic board
    in
    board
        |> Board.secondLastMove
        |> Maybe.map (\m -> Board.updateAt (Check.coord m) Block.clearBearing newBoard)
        |> Maybe.withDefault newBoard



-- Valid Moves


isValidNextMove : Move -> Board -> Bool
isValidNextMove move board =
    List.foldl (\check isValid -> isValid || check move board) False checks


checks : List (Move -> Board -> Bool)
checks =
    [ isValidStandardMove
    , Burst.isValidNextMove
    , Pod.isValidNextMove
    ]


isValidStandardMove : Move -> Board -> Bool
isValidStandardMove move board =
    Check.isNewNeighbour move board && Check.sameActiveTileType move board



-- Helpers


isFirstMove : Board -> Bool
isFirstMove =
    Board.activeMoves >> List.length >> (==) 0
