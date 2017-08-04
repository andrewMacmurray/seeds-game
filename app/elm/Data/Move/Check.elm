module Data.Move.Check exposing (..)

import Data.Board.Tile exposing (addBearing, isCurrentMove, isDragging, moveOrder, setStaticToFirstMove, setToDragging)
import Data.Move.Bearing exposing (addBearings)
import Data.Move.Direction exposing (isAbove, isBelow, isLeft, isRight, validDirection)
import Data.Move.Square exposing (isValidSquare, triggerMoveIfSquare)
import Data.Move.Type exposing (emptyMove, moveShape, sameTileType)
import Data.Move.Utils exposing (currentMoves, isUniqueMove, lastMove)
import Dict
import Scenes.Level.Model exposing (..)


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


handleCheckMove : Move -> Model -> ( Model, Cmd Msg )
handleCheckMove move model =
    let
        newModel =
            model |> handleCheckMove_ move
    in
        newModel ! [ triggerMoveIfSquare newModel ]


handleCheckMove_ : Move -> Model -> Model
handleCheckMove_ move model =
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
