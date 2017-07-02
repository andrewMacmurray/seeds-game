module Data.Moves.Type exposing (..)

import Data.Tiles exposing (getTileType, isDragging)
import Dict.Extra
import Model exposing (..)


currentMoveType : Board -> Maybe TileType
currentMoveType board =
    board
        |> Dict.Extra.find (\_ tile -> isDragging tile)
        |> Maybe.andThen moveType


moveType : Move -> Maybe TileType
moveType ( _, tileState ) =
    case tileState of
        Dragging tile _ _ ->
            Just tile

        _ ->
            Nothing


sameTileType : Move -> Move -> Bool
sameTileType ( _, t2 ) ( _, t1 ) =
    getTileType t1 == getTileType t2


emptyMove : Move
emptyMove =
    ( ( 0, 0 ), Empty )
