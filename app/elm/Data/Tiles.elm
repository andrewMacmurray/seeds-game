module Data.Tiles exposing (..)

import Model exposing (..)


evenTiles : Int -> TileType
evenTiles n =
    if n > 65 then
        SeedPod
    else if n > 30 then
        Seed
    else if n > 20 then
        Rain
    else
        Sun


growingOrder : TileState -> Int
growingOrder tileState =
    case tileState of
        Growing _ order ->
            order

        _ ->
            0


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


setGrowingToStatic : TileState -> TileState
setGrowingToStatic tileState =
    case tileState of
        Growing Seed _ ->
            Static Seed

        x ->
            x


growSeedPod : TileState -> TileState
growSeedPod tileState =
    case tileState of
        Growing SeedPod n ->
            Growing Seed n

        x ->
            x


setToFalling : Int -> TileState -> TileState
setToFalling fallingDistance tileState =
    case tileState of
        Static tile ->
            Falling tile fallingDistance

        x ->
            x


setEnteringToStatic : TileState -> TileState
setEnteringToStatic tileState =
    case tileState of
        Entering tile ->
            Static tile

        x ->
            x


setFallingToStatic : TileState -> TileState
setFallingToStatic tileState =
    case tileState of
        Falling tile _ ->
            Static tile

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

        Entering tile ->
            tileColors tile

        Growing tile _ ->
            tileColors tile

        _ ->
            ""


tilePaddingMap : TileState -> ( String, String )
tilePaddingMap tileState =
    case tileState of
        Static tile ->
            tilePadding tile

        Leaving tile _ ->
            tilePadding tile

        Falling tile _ ->
            tilePadding tile

        Entering tile ->
            tilePadding tile

        Growing tile _ ->
            tilePadding tile

        _ ->
            ( "", "" )


tileColors : TileType -> String
tileColors tile =
    case tile of
        Rain ->
            "bg-light-blue"

        Sun ->
            "bg-gold"

        SeedPod ->
            "bg-seed-pod"

        Seed ->
            "bg-sunflower"


tilePadding : TileType -> ( String, String )
tilePadding tile =
    case tile of
        Rain ->
            ( "padding", "9px" )

        Sun ->
            ( "padding", "9px" )

        SeedPod ->
            ( "padding", "13px" )

        Seed ->
            ( "padding", "17px" )
