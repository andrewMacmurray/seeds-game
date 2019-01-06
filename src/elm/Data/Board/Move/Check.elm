module Data.Board.Move.Check exposing
    ( addMoveToBoard
    , startMove
    )

import Data.Board as Board
import Data.Board.Block as Block
import Data.Board.Move as Move
import Data.Board.Move.Bearing as Bearing
import Data.Board.Types exposing (..)
import Dict


startMove : Move -> Board -> Board
startMove move =
    Board.update (Move.coord move) Block.setStaticToFirstMove


addMoveToBoard : Move -> Board -> Board
addMoveToBoard curr board =
    if isValidMove curr board || isValidBurst curr board then
        Bearing.add curr board

    else if shouldRemoveMove curr board then
        removeLastMove board

    else
        board


removeLastMove : Board -> Board
removeLastMove board =
    let
        lastCoord =
            Move.coord <| Move.last board

        newBoard =
            Board.update lastCoord Block.setDraggingToStatic board
    in
    board
        |> Move.secondLast
        |> Maybe.map (\m -> Board.update (Move.coord m) Block.removeBearing newBoard)
        |> Maybe.withDefault newBoard


shouldRemoveMove : Move -> Board -> Bool
shouldRemoveMove curr board =
    Just curr == Move.secondLast board


isValidBurst : Move -> Board -> Bool
isValidBurst curr board =
    let
        last =
            Move.last board

        burstTypeNotSet =
            Move.currentMoveTileType board == Nothing

        isValidMoveAfterBurst =
            isBurst last && Move.currentMoveTileType board == Move.tileType curr

        inCurrentMoves =
            Move.inCurrentMoves curr board
    in
    (isBurst curr || isValidMoveAfterBurst || burstTypeNotSet)
        && Move.areNeighbours curr last
        && not inCurrentMoves


isValidMove : Move -> Board -> Bool
isValidMove curr board =
    let
        last =
            Move.last board

        inCurrentMoves =
            Move.inCurrentMoves curr board
    in
    Move.areNeighbours curr last
        && Move.sameTileType curr last
        && not inCurrentMoves


isBurst : Move -> Bool
isBurst =
    Move.block >> Block.isBurst
