module Data.Board.Move.Check exposing
    ( addMoveToBoard
    , startMove
    )

import Data.Board.Block as Block
import Data.Board.Move as Move
import Data.Board.Move.Bearing as Bearing
import Data.Board.Types exposing (..)
import Dict


startMove : Move -> Board -> Board
startMove ( c1, t1 ) board =
    board |> Dict.update c1 (Maybe.map (\_ -> Block.setStaticToFirstMove t1))


addMoveToBoard : Move -> Board -> Board
addMoveToBoard curr board =
    if isValidMove curr board || isValidBurst curr board then
        Bearing.add curr board

    else
        board


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
isBurst ( _, block ) =
    Block.isBurst block
