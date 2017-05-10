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


setToFalling : Int -> TileState -> TileState
setToFalling fallingDistance tileState =
    case tileState of
        Static tile ->
            Falling tile fallingDistance

        x ->
            x


setLeavingToEmpty : TileState -> TileState
setLeavingToEmpty tileState =
    case tileState of
        Leaving _ _ ->
            Empty

        x ->
            x


setToGrowing : Int -> TileState -> TileState
setToGrowing order tileState =
    case tileState of
        Static SeedPod ->
            Growing SeedPod order

        x ->
            x


setToLeaving : Int -> TileState -> TileState
setToLeaving order tileState =
    case tileState of
        Static Rain ->
            Leaving Rain order

        Static Sun ->
            Leaving Sun order

        Static Seed ->
            Leaving Seed order

        x ->
            x


tileColorMap : TileState -> String
tileColorMap tileState =
    case tileState of
        Static tile ->
            tileColors tile

        Leaving tile _ ->
            tileColors tile

        Falling tile _ ->
            tileColors tile

        Growing tile _ ->
            tileColors tile

        _ ->
            ""


tilePaddingMap : TileState -> String
tilePaddingMap tileState =
    case tileState of
        Static tile ->
            tilePadding tile

        Leaving tile _ ->
            tilePadding tile

        Falling tile _ ->
            tilePadding tile

        Growing tile _ ->
            tilePadding tile

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
