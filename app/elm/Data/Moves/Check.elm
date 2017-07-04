module Data.Moves.Check exposing (..)

import Data.Moves.Bearings exposing (addBearings)
import Data.Moves.Directions exposing (isAbove, isBelow, isLeft, isRight, validDirection)
import Data.Moves.Square exposing (isValidSquare)
import Data.Moves.Type exposing (emptyMove, moveShape, sameTileType)
import Data.Moves.Utils exposing (currentMoves, lastMove)
import Data.Tiles exposing (addBearing, isCurrentMove, isDragging, moveOrder, setStaticToFirstMove, setToDragging)
import Dict
import Model exposing (..)


handleStopMove : Model -> Model
handleStopMove model =
    { model
        | isDragging = False
        , moveShape = Nothing
    }


handleStartMove : Move -> Model -> Model
handleStartMove move model =
    { model
        | isDragging = True
        , board = startMove move model.board
        , moveShape = Just Line
    }


handleCheckMove : Move -> Model -> Model
handleCheckMove move model =
    if model.isDragging then
        { model | board = addToMove move model.board }
    else
        model


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


isUniqueMove : Move -> Board -> Bool
isUniqueMove move board =
    isInCurrentMoves move board
        |> not


isInCurrentMoves : Move -> Board -> Bool
isInCurrentMoves move board =
    board
        |> currentMoves
        |> List.member move
