module Data.Level.Move.Utils exposing (..)

import Data.Level.Board.Tile exposing (getTileType, isCurrentMove, isDragging, moveOrder)
import Scenes.Level.Types exposing (..)
import Dict
import Helpers.Dict exposing (find)


currentMoveTileType : Board -> Maybe TileType
currentMoveTileType board =
    board
        |> find (\_ tile -> isDragging tile)
        |> Maybe.andThen moveTileType


moveShape : Move -> Maybe MoveShape
moveShape ( _, block ) =
    case block of
        Space (Dragging _ _ _ moveShape) ->
            Just moveShape

        _ ->
            Nothing


moveTileType : Move -> Maybe TileType
moveTileType ( _, block ) =
    case block of
        Space (Dragging tile _ _ _) ->
            Just tile

        _ ->
            Nothing


sameTileType : Move -> Move -> Bool
sameTileType ( _, t2 ) ( _, t1 ) =
    getTileType t1 == getTileType t2


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
        |> find isCurrentMove_
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


emptyMove : Move
emptyMove =
    ( ( 0, 0 ), Space Empty )
