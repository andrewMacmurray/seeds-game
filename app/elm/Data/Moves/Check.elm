module Data.Moves.Check exposing (..)

import Data.Directions exposing (validDirection)
import Data.Moves.Square exposing (isValidSquare)
import Data.Moves.Type exposing (sameTileType, emptyMove)
import Delay
import Model exposing (..)


handleStopMove : Model -> Model
handleStopMove model =
    { model
        | isDragging = False
        , currentMove = []
        , moveType = Nothing
    }


handleStartMove : Move -> Model -> Model
handleStartMove move model =
    { model
        | isDragging = True
        , currentMove = [ move ]
        , moveType = Just Line
    }


triggerMoveIfSquare : Model -> Cmd Msg
triggerMoveIfSquare model =
    if isValidSquare model.currentMove then
        Delay.after 0 SquareMove
    else
        Cmd.none


handleCheckMove : Move -> Model -> Model
handleCheckMove move model =
    if model.isDragging then
        { model | currentMove = addToMove move model.currentMove }
    else
        model


addToMove : Move -> List Move -> List Move
addToMove next currentMoves =
    if isValidMove next currentMoves || isValidSquare (next :: currentMoves) then
        next :: currentMoves
    else
        currentMoves


isValidMove : Move -> List Move -> Bool
isValidMove next currentMoves =
    let
        curr =
            currentMove currentMoves
    in
        validDirection next curr
            && sameTileType next curr
            && isUniqueMove next currentMoves


isUniqueMove : Move -> List Move -> Bool
isUniqueMove next currentMoves =
    isInCurrentMove next currentMoves
        |> not


isInCurrentMove : Move -> List Move -> Bool
isInCurrentMove next currentMoves =
    currentMoves |> List.member next


currentMove : List Move -> Move
currentMove currentMoves =
    List.head currentMoves
        |> Maybe.withDefault emptyMove


coordsList : List Move -> List Coord
coordsList moves =
    moves |> List.map Tuple.first
