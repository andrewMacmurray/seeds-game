module Data.Board.Move.Check exposing (..)

import Data.Board.Move.Square exposing (isValidSquare)
import Data.Board exposing (Board, Move)
import Data.Board.Move.Bearing exposing (addBearings, validDirection)
import Data.Board.Move exposing (lastMove, sameTileType, isUniqueMove)
import Data.Board.Block exposing (setStaticToFirstMove)
import Dict


addToMove : Move -> Board -> Board
addToMove curr board =
    let
        newBoard =
            addBearings curr board
    in
        if isValidMove curr board || isValidSquare curr board then
            newBoard
        else
            board


startMove : Move -> Board -> Board
startMove ( c1, t1 ) board =
    board |> Dict.update c1 (Maybe.map (\_ -> setStaticToFirstMove t1))


isValidMove : Move -> Board -> Bool
isValidMove curr board =
    let
        last =
            lastMove board
    in
        validDirection curr last
            && sameTileType curr last
            && isUniqueMove curr board
