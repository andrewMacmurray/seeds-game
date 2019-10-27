module Board.Move.Check exposing
    ( addMoveToBoard
    , startMove
    )

import Board exposing (Board)
import Board.Block as Block
import Board.Move as Move exposing (Move)
import Board.Move.Bearing as Bearing


startMove : Move -> Board -> Board
startMove move =
    Board.updateAt (Move.coord move) Block.setStaticToFirstMove


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
            Move.coord <| Board.lastMove board

        newBoard =
            Board.updateAt lastCoord Block.setDraggingToStatic board
    in
    board
        |> Board.secondLastMove
        |> Maybe.map (\m -> Board.updateAt (Move.coord m) Block.clearBearing newBoard)
        |> Maybe.withDefault newBoard


shouldRemoveMove : Move -> Board -> Bool
shouldRemoveMove curr board =
    Just curr == Board.secondLastMove board


isValidBurst : Move -> Board -> Bool
isValidBurst curr board =
    let
        last =
            Board.lastMove board

        burstTypeNotSet =
            Board.currentTile board == Nothing

        isValidMoveAfterBurst =
            isBurst last && Board.currentTile board == Move.tile curr

        inCurrentMoves =
            Board.inCurrentMoves curr board
    in
    (isBurst curr || isValidMoveAfterBurst || burstTypeNotSet)
        && Move.areNeighbours curr last
        && not inCurrentMoves


isValidMove : Move -> Board -> Bool
isValidMove curr board =
    let
        last =
            Board.lastMove board

        inCurrentMoves =
            Board.inCurrentMoves curr board
    in
    Move.areNeighbours curr last
        && Move.sameTileType curr last
        && not inCurrentMoves


isBurst : Move -> Bool
isBurst =
    Move.block >> Block.isBurst