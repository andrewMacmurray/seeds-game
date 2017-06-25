module Data.Moves.Type exposing (..)

import Data.Tiles exposing (getTileType)
import Model exposing (..)


currentMoveType : List Move -> Maybe TileType
currentMoveType moveList =
    moveList
        |> List.head
        |> Maybe.andThen moveType


moveType : Move -> Maybe TileType
moveType ( _, tileState ) =
    case tileState of
        Static tile ->
            Just tile

        _ ->
            Nothing


sameTileType : Move -> Move -> Bool
sameTileType ( _, t2 ) ( _, t1 ) =
    getTileType t1 == getTileType t2


emptyMove : Move
emptyMove =
    ( ( 0, 0 ), Empty )
