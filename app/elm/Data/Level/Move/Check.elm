module Data.Level.Move.Check exposing (..)

import Data.Level.Board.Tile exposing (addBearing, isCurrentMove, isDragging, moveOrder, setStaticToFirstMove, setToDragging)
import Data.Level.Move.Bearing exposing (addBearings)
import Data.Level.Move.Direction exposing (isAbove, isBelow, isLeft, isRight, validDirection)
import Data.Level.Move.Square exposing (isValidSquare, triggerMoveIfSquare)
import Data.Level.Move.Type exposing (emptyMove, moveShape, sameTileType)
import Data.Level.Move.Utils exposing (currentMoves, isUniqueMove, lastMove)
import Dict
import Scenes.Level.Model exposing (..)


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
