module Data.Moves.Utils exposing (..)

import Data.Moves.Type exposing (emptyMove)
import Data.Tiles exposing (isCurrentMove, isDragging, moveOrder)
import Dict
import Dict.Extra
import Model exposing (..)


isUniqueMove : Move -> Board -> Bool
isUniqueMove move board =
    isInCurrentMoves move board
        |> not


isInCurrentMoves : Move -> Board -> Bool
isInCurrentMoves move board =
    board
        |> currentMoves
        |> List.member move


lastMove : Board -> Move
lastMove board =
    board
        |> Dict.Extra.find isCurrentMove_
        |> Maybe.withDefault emptyMove


coordsList : Board -> List Coord
coordsList board =
    board
        |> Dict.filter isDragging_
        |> Dict.keys


currentMoves : Board -> List Move
currentMoves board =
    board
        |> Dict.filter isDragging_
        |> Dict.toList
        |> List.sortBy moveOrder_


isCurrentMove_ : Coord -> Block -> Bool
isCurrentMove_ _ =
    isCurrentMove


isDragging_ : Coord -> Block -> Bool
isDragging_ _ =
    isDragging


moveOrder_ : Move -> Int
moveOrder_ ( _, tileState ) =
    moveOrder tileState
