module Data.Board.Tile exposing
    ( addBearing
    , baseSizeX
    , baseSizeY
    , getSeedType
    , getTileType
    , growSeedPod
    , growingOrder
    , hasLine
    , hash
    , seedTypeHash
    , isCurrentMove
    , isDragging
    , isFalling
    , isGrowing
    , isLeaving
    , isSeed
    , leavingOrder
    , map
    , moveOrder
    , scale
    , seedName
    , setDraggingToGrowing
    , setEnteringToSatic
    , setFallingToStatic
    , setGrowingToStatic
    , setLeavingToEmpty
    , setStaticToFirstMove
    , setToDragging
    , setToFalling
    , setToLeaving
    )

import Data.Board.Types exposing (..)
import Data.Window as Window


map : a -> (TileType -> a) -> TileState -> a
map default fn tileState =
    tileState
        |> getTileType
        |> Maybe.map fn
        |> Maybe.withDefault default


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


isGrowing : TileState -> Bool
isGrowing tileState =
    case tileState of
        Growing _ _ ->
            True

        _ ->
            False


isFalling : TileState -> Bool
isFalling tileState =
    case tileState of
        Falling _ _ ->
            True

        _ ->
            False


hasLine : TileState -> Bool
hasLine tileState =
    case tileState of
        Dragging _ _ Left _ ->
            True

        Dragging _ _ Right _ ->
            True

        Dragging _ _ Up _ ->
            True

        Dragging _ _ Down _ ->
            True

        _ ->
            False


moveOrder : TileState -> Int
moveOrder tileState =
    case tileState of
        Dragging _ moveOrder_ _ _ ->
            moveOrder_

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
setToDragging moveOrder_ tileState =
    case tileState of
        Static tileType ->
            Dragging tileType moveOrder_ Head Line

        Dragging tileType _ bearing _ ->
            Dragging tileType moveOrder_ bearing Square

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
        Dragging tileType moveOrder_ _ moveShape ->
            Dragging tileType moveOrder_ moveBearing moveShape

        x ->
            x


setGrowingToStatic : TileState -> TileState
setGrowingToStatic tileState =
    case tileState of
        Growing (Seed seedType) _ ->
            Static (Seed seedType)

        x ->
            x


growSeedPod : SeedType -> TileState -> TileState
growSeedPod seedType tileState =
    case tileState of
        Growing SeedPod n ->
            Growing (Seed seedType) n

        x ->
            x


setToFalling : Int -> TileState -> TileState
setToFalling fallingDistance tileState =
    case tileState of
        Static tile ->
            Falling tile fallingDistance

        Falling tile _ ->
            Falling tile fallingDistance

        x ->
            x


setEnteringToSatic : TileState -> TileState
setEnteringToSatic tileState =
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

        Dragging (Seed seedType) order _ _ ->
            Leaving (Seed seedType) order

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


isSeed : TileType -> Bool
isSeed tileType =
    case tileType of
        Seed _ ->
            True

        _ ->
            False


getSeedType : TileType -> Maybe SeedType
getSeedType tileType =
    case tileType of
        Seed seedType ->
            Just seedType

        _ ->
            Nothing


seedName : SeedType -> String
seedName seedType =
    case seedType of
        Sunflower ->
            "Sunflower"

        Chrysanthemum ->
            "Chrysanthemum"

        Cornflower ->
            "Cornflower"

        Lupin ->
            "Lupin"

        Marigold ->
            "Marigold"

        Rose ->
            "Rose"


hash : TileType -> String
hash tileType =
    case tileType of
        Rain ->
            "rain"

        Sun ->
            "sun"

        SeedPod ->
            "seed-pod"

        Seed seedType ->
            seedTypeHash seedType


seedTypeHash : SeedType -> String
seedTypeHash seedType =
    case seedType of
        Sunflower ->
            "sunflower"

        Chrysanthemum ->
            "chrysanthemum"

        Cornflower ->
            "cornflower"

        Lupin ->
            "lupin"

        Marigold ->
            "marigold"

        Rose ->
            "rose"


scale : Window.Window -> Float
scale window =
    case Window.size window of
        Window.Small ->
            0.8

        Window.Medium ->
            0.98

        Window.Large ->
            1.2


baseSizeX : number
baseSizeX =
    55


baseSizeY : number
baseSizeY =
    51
