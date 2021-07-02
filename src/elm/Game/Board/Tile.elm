module Game.Board.Tile exposing
    ( Bearing(..)
    , Distance
    , MoveOrder
    , State(..)
    , Tile(..)
    , addBearing
    , clearBurstType
    , get
    , growLeavingBurstToSeed
    , growingOrder
    , isBurst
    , isCollectible
    , isCurrentMove
    , isDragging
    , isEmpty
    , isFalling
    , isGrowing
    , isLeaving
    , isReleasing
    , isSeed
    , leavingOrder
    , map
    , moveOrder
    , releaseDraggingSeeds
    , removeBearing
    , seedType
    , setActiveToStatic
    , setDraggingBurstType
    , setDraggingToGrowing
    , setDraggingToLeaving
    , setDraggingToStatic
    , setEnteringToStatic
    , setFallingToStatic
    , setGrowingToStatic
    , setLeavingToEmpty
    , setReleasingToStatic
    , setStaticToFirstMove
    , setToActive
    , setToDragging
    , setToFalling
    , toString
    )

import Seed



-- Tile


type Tile
    = Rain
    | Sun
    | Seed Seed.Seed
    | SeedPod
    | Burst (Maybe Tile)



-- Tile State


type State
    = Static Tile
    | Dragging Tile MoveOrder Bearing
    | Leaving Tile MoveOrder
    | Falling Tile Distance
    | Entering Tile
    | Growing Tile MoveOrder
    | Active Tile
    | Releasing Tile MoveOrder
    | Empty


type Bearing
    = Head
    | Left
    | Right
    | Up
    | Down


type alias Distance =
    Int


type alias MoveOrder =
    Int



-- Query


growingOrder : State -> Int
growingOrder tileState =
    case tileState of
        Growing _ order ->
            order

        _ ->
            0


leavingOrder : State -> Int
leavingOrder tileState =
    case tileState of
        Leaving _ order ->
            order

        _ ->
            0


isEmpty : State -> Bool
isEmpty tileState =
    case tileState of
        Empty ->
            True

        _ ->
            False


isLeaving : State -> Bool
isLeaving tileState =
    case tileState of
        Leaving _ _ ->
            True

        _ ->
            False


isDragging : State -> Bool
isDragging tileState =
    case tileState of
        Dragging _ _ _ ->
            True

        _ ->
            False


isReleasing : State -> Bool
isReleasing tileState =
    case tileState of
        Releasing _ _ ->
            True

        _ ->
            False


isGrowing : State -> Bool
isGrowing tileState =
    case tileState of
        Growing _ _ ->
            True

        _ ->
            False


isFalling : State -> Bool
isFalling tileState =
    case tileState of
        Falling _ _ ->
            True

        _ ->
            False


moveOrder : State -> Int
moveOrder tileState =
    case tileState of
        Dragging _ moveOrder_ _ ->
            moveOrder_

        _ ->
            0


isCurrentMove : State -> Bool
isCurrentMove tileState =
    case tileState of
        Dragging _ _ Head ->
            True

        _ ->
            False


isSeed : Tile -> Bool
isSeed tileType =
    case tileType of
        Seed _ ->
            True

        _ ->
            False


isBurst : Tile -> Bool
isBurst tileType =
    case tileType of
        Burst _ ->
            True

        _ ->
            False


isCollectible : Tile -> Bool
isCollectible tileType =
    case tileType of
        Rain ->
            True

        Sun ->
            True

        Seed _ ->
            True

        _ ->
            False



-- Update


setToDragging : MoveOrder -> State -> State
setToDragging moveOrder_ tileState =
    case tileState of
        Static tileType ->
            Dragging tileType moveOrder_ Head

        Active tileType ->
            Dragging tileType moveOrder_ Head

        x ->
            x


growLeavingBurstToSeed : Seed.Seed -> State -> State
growLeavingBurstToSeed seed tileState =
    case tileState of
        Leaving (Burst (Just SeedPod)) moveOrder_ ->
            Growing (Seed seed) moveOrder_

        x ->
            x


releaseDraggingSeeds : State -> State
releaseDraggingSeeds tileState =
    case tileState of
        Dragging (Seed seed) moveOrder_ _ ->
            Releasing (Seed seed) moveOrder_

        x ->
            x


setReleasingToStatic : State -> State
setReleasingToStatic tileState =
    case tileState of
        Releasing tile _ ->
            Static tile

        x ->
            x


setToActive : State -> State
setToActive tileState =
    case tileState of
        Static tileType ->
            Active tileType

        x ->
            x


setActiveToStatic : State -> State
setActiveToStatic tileState =
    case tileState of
        Active tileType ->
            Static tileType

        x ->
            x


removeBearing : State -> State
removeBearing tileState =
    case tileState of
        Dragging tileType moveOrder_ _ ->
            Dragging tileType moveOrder_ Head

        x ->
            x


setStaticToFirstMove : State -> State
setStaticToFirstMove tileState =
    case tileState of
        Static tileType ->
            Dragging tileType 1 Head

        x ->
            x


addBearing : Bearing -> State -> State
addBearing bearing tileState =
    case tileState of
        Dragging tileType moveOrder_ _ ->
            Dragging tileType moveOrder_ bearing

        x ->
            x


setGrowingToStatic : State -> State
setGrowingToStatic tileState =
    case tileState of
        Growing (Seed seed) _ ->
            Static (Seed seed)

        x ->
            x


setDraggingBurstType : Tile -> State -> State
setDraggingBurstType tileType tileState =
    case tileState of
        Dragging (Burst _) moveOrder_ bearing ->
            Dragging (Burst (Just tileType)) moveOrder_ bearing

        x ->
            x


clearBurstType : State -> State
clearBurstType tileState =
    case tileState of
        Dragging (Burst _) moveOrder_ bearing ->
            Dragging (Burst Nothing) moveOrder_ bearing

        Leaving (Burst _) moveOrder_ ->
            Leaving (Burst Nothing) moveOrder_

        x ->
            x


setToFalling : Int -> State -> State
setToFalling fallingDistance tileState =
    case tileState of
        Static tile ->
            Falling tile fallingDistance

        Falling tile _ ->
            Falling tile fallingDistance

        x ->
            x


setEnteringToStatic : State -> State
setEnteringToStatic tileState =
    case tileState of
        Entering tile ->
            Static tile

        x ->
            x


setFallingToStatic : State -> State
setFallingToStatic tileState =
    case tileState of
        Falling tile _ ->
            Static tile

        x ->
            x


setLeavingToEmpty : State -> State
setLeavingToEmpty tileState =
    case tileState of
        Leaving _ _ ->
            Empty

        x ->
            x


setDraggingToStatic : State -> State
setDraggingToStatic tileState =
    case tileState of
        Dragging tile _ _ ->
            Static (resetBurstType tile)

        x ->
            x


setDraggingToGrowing : State -> State
setDraggingToGrowing tileState =
    case tileState of
        Dragging SeedPod order _ ->
            Growing SeedPod order

        x ->
            x


setDraggingToLeaving : State -> State
setDraggingToLeaving tileState =
    case tileState of
        Dragging tile order _ ->
            Leaving tile order

        x ->
            x


resetBurstType : Tile -> Tile
resetBurstType tileType =
    case tileType of
        Burst _ ->
            Burst Nothing

        x ->
            x


seedType : Tile -> Maybe Seed.Seed
seedType tileType =
    case tileType of
        Seed seedType_ ->
            Just seedType_

        _ ->
            Nothing



-- Helpers


map : a -> (Tile -> a) -> State -> a
map default fn =
    get
        >> Maybe.map fn
        >> Maybe.withDefault default


get : State -> Maybe Tile
get tileState =
    case tileState of
        Static tile ->
            Just tile

        Dragging tile _ _ ->
            Just tile

        Leaving tile _ ->
            Just tile

        Falling tile _ ->
            Just tile

        Entering tile ->
            Just tile

        Growing tile _ ->
            Just tile

        Active tile ->
            Just tile

        Releasing tile _ ->
            Just tile

        Empty ->
            Nothing


toString : Tile -> String
toString tileType =
    case tileType of
        Rain ->
            "Rain"

        Sun ->
            "Sun"

        SeedPod ->
            "SeedPod"

        Seed seed ->
            Seed.name seed

        Burst tile ->
            burstToString tile


burstToString : Maybe Tile -> String
burstToString =
    Maybe.map (\tile -> "Burst" ++ toString tile) >> Maybe.withDefault "BurstEmpty"
