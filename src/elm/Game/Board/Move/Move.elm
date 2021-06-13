module Game.Board.Move.Move exposing (drag)

import Game.Board as Board exposing (Board)
import Game.Board.Block as Block
import Game.Board.Mechanic.Burst as Burst
import Game.Board.Mechanic.Pod as Pod
import Game.Board.Move as Move exposing (Move)
import Game.Board.Move.Bearing as Bearing
import Game.Board.Move.Check as Check



-- Drag


drag : Board.Size -> Move -> Board -> Board
drag boardSize move board =
    if isFirstMove board then
        makeFirstMove move board

    else if shouldUndoMove move board then
        undoLastMove board |> Burst.drag boardSize

    else if isValidNextMove move board then
        Bearing.add move board |> Burst.drag boardSize

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
    isNotWall move
        && Check.isNewNeighbour move board
        && anyChecksPass move board


anyChecksPass : Move -> Board -> Bool
anyChecksPass move board =
    List.foldl (\check isValid -> isValid || check move board) False checks


checks : List (Move -> Board -> Bool)
checks =
    [ isValidStandardMove
    , Burst.isValidNextMove
    , Pod.isValidNextMove
    ]


isValidStandardMove : Move -> Board -> Bool
isValidStandardMove move board =
    Check.sameActiveTileType move board



-- Helpers


isFirstMove : Board -> Bool
isFirstMove =
    Board.activeMoves >> List.length >> (==) 0


isNotWall : Move -> Bool
isNotWall =
    Move.block >> Block.isWall >> not
