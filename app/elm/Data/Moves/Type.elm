module Data.Moves.Type exposing (..)

import Model exposing (..)


currentMoveType : List Move -> Tile
currentMoveType moveList =
    moveList
        |> List.head
        |> Maybe.map moveType
        |> Maybe.withDefault Rain


moveType : Move -> Tile
moveType ( _, tileState ) =
    case tileState of
        Static tile ->
            tile

        _ ->
            Rain
