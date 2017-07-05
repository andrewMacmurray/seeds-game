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


isDragging : TileState -> Bool
isDragging tileState =
    case tileState of
        Dragging _ _ _ _ ->
            True

        _ ->
            False


moveOrder : TileState -> Int
moveOrder tileState =
    case tileState of
        Dragging _ moveOrder _ _ ->
            moveOrder

        _ ->
            0


isCurrentMove : TileState -> Bool
isCurrentMove tileState =
    case tileState of
        Dragging _ _ Head _ ->
            True

        _ ->
            False


setToDragging : MoveOrder -> TileState -> TileState
setToDragging moveOrder tileState =
    case tileState of
        Static tileType ->
            Dragging tileType moveOrder Head Line

        Dragging tileType _ _ _ ->
            Dragging tileType moveOrder Head Square

        x ->
            x


setStaticToFirstMove : TileState -> TileState
setStaticToFirstMove tileState =
    case tileState of
        Static tileType ->
            Dragging tileType 1 Head Line

        x ->
            x


addBearing : MoveBearing -> TileState -> TileState
addBearing moveBearing tileState =
    case tileState of
        Dragging tileType moveOrder _ moveShape ->
            Dragging tileType moveOrder moveBearing moveShape

        x ->
            x


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


setDraggingToGrowing : TileState -> TileState
setDraggingToGrowing tileState =
    case tileState of
        Dragging SeedPod order _ _ ->
            Growing SeedPod order

        x ->
            x


setToLeaving : TileState -> TileState
setToLeaving tileState =
    case tileState of
        Dragging Rain order _ _ ->
            Leaving Rain order

        Dragging Sun order _ _ ->
            Leaving Sun order

        Dragging Seed order _ _ ->
            Leaving Seed order

        x ->
            x


getTileType : TileState -> Maybe TileType
getTileType tileState =
    case tileState of
        Static tile ->
            Just tile

        Dragging tile _ _ _ ->
            Just tile

        Leaving tile _ ->
            Just tile

        Falling tile _ ->
            Just tile

        Entering tile ->
            Just tile

        Growing tile _ ->
            Just tile

        _ ->
            Nothing


tileColorMap : TileState -> String
tileColorMap tileState =
    case tileState of
        Static tile ->
            tileColors tile

        Dragging tile _ _ _ ->
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

        Dragging tile _ _ _ ->
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
