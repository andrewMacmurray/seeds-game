module Data.Moves.Check exposing (..)

import Model exposing (..)
import Data.Directions exposing (validDirection)


handleStopMove : Model -> Model
handleStopMove model =
    { model
        | isDragging = False
        , currentMove = []
    }


handleStartMove : Move -> Model -> Model
handleStartMove move model =
    { model
        | isDragging = True
        , currentMove = [ move ]
    }


handleCheckMove : Move -> Model -> Model
handleCheckMove move model =
    if model.isDragging then
        { model | currentMove = addToMove move model.currentMove }
    else
        model


addToMove : Move -> List Move -> List Move
addToMove next currentMoves =
    if isValidMove next currentMoves then
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


sameTileType : Move -> Move -> Bool
sameTileType ( _, t2 ) ( _, t1 ) =
    t1 == t2


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


emptyMove : Move
emptyMove =
    ( ( 0, 0 ), Empty )
