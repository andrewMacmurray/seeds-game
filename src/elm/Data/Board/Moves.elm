module Data.Board.Moves
    exposing
        ( currentMoveTileType
        , currentMoves
        , emptyMove
        , isUniqueMove
        , lastMove
        , moveShape
        , sameTileType
        )

import Data.Board.Block as Block
import Data.Board.Types exposing (..)
import Dict
import Helpers.Dict exposing (filterValues, find, findValue)


currentMoves : Board -> List Move
currentMoves board =
    board
        |> filterValues Block.isDragging
        |> Dict.toList
        |> List.sortBy (Tuple.second >> Block.moveOrder)


currentMoveTileType : Board -> Maybe TileType
currentMoveTileType board =
    board
        |> findValue Block.isDragging
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
    Block.getTileType t1 == Block.getTileType t2


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
        |> findValue Block.isCurrentMove
        |> Maybe.withDefault emptyMove


coordsList : Board -> List Coord
coordsList board =
    board
        |> filterValues Block.isDragging
        |> Dict.keys


emptyMove : Move
emptyMove =
    ( ( 0, 0 ), Space Empty )
