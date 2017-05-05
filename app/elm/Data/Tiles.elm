module Data.Tiles exposing (..)

import Model exposing (..)


evenTiles : Int -> Tile
evenTiles n =
    if n > 90 then
        Seed
    else if n > 30 then
        SeedPod
    else if n > 20 then
        Rain
    else
        Sun


leavingOrder : TileState -> Int
leavingOrder tileState =
    case tileState of
        Leaving _ order ->
            order

        _ ->
            0


isLeaving : TileState -> Bool
isLeaving tileState =
    case tileState of
        Leaving _ _ ->
            True

        _ ->
            False


setToLeaving : Int -> TileState -> TileState
setToLeaving order tileState =
    case tileState of
        Static tile ->
            Leaving tile order

        x ->
            x


tileColorMap : TileState -> String
tileColorMap tileState =
    case tileState of
        Static tile ->
            tileColors tile

        Leaving tile _ ->
            tileColors tile

        _ ->
            ""


tileColors : Tile -> String
tileColors tile =
    case tile of
        Rain ->
            "bg-light-blue"

        Sun ->
            "bg-gold"

        SeedPod ->
            "bg-seed-pod"

        Seed ->
            "bg-seed"


tilePaddingMap : TileState -> String
tilePaddingMap tileState =
    case tileState of
        Static tile ->
            tilePadding tile

        Leaving tile _ ->
            tilePadding tile

        _ ->
            ""


tilePadding : Tile -> String
tilePadding tile =
    case tile of
        Rain ->
            "9px"

        Sun ->
            "9px"

        SeedPod ->
            "13px"

        Seed ->
            "17px"
