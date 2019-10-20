module Data.Board.Tile exposing
    ( Bearing(..)
    , Distance
    , MoveOrder
    , SeedType(..)
    , State(..)
    , Type(..)
    , addBearing
    , baseSizeX
    , baseSizeY
    , clearBurstType
    , getSeedType
    , getType
    , growLeavingBurstToSeed
    , growSeedPod
    , growingOrder
    , hasLine
    , hash
    , isBurst
    , isCollectible
    , isCurrentMove
    , isDragging
    , isEmpty
    , isFalling
    , isGrowing
    , isLeaving
    , isSeed
    , leavingOrder
    , map
    , moveOrder
    , removeBearing
    , scale
    , seedName
    , setActiveToStatic
    , setDraggingBurstType
    , setDraggingToGrowing
    , setDraggingToLeaving
    , setDraggingToStatic
    , setEnteringToStatic
    , setFallingToStatic
    , setGrowingToStatic
    , setLeavingToEmpty
    , setStaticToFirstMove
    , setToActive
    , setToDragging
    , setToFalling
    )

import Data.Window as Window



-- Tile Type


type Type
    = Rain
    | Sun
    | SeedPod
    | Seed SeedType
    | Burst (Maybe Type)


type SeedType
    = Sunflower
    | Chrysanthemum
    | Cornflower
    | Lupin
    | Marigold
    | Rose



-- Tile State


type State
    = Static Type
    | Dragging Type MoveOrder Bearing
    | Leaving Type MoveOrder
    | Falling Type Distance
    | Entering Type
    | Growing Type MoveOrder
    | Active Type
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


hasLine : State -> Bool
hasLine tileState =
    case tileState of
        Dragging _ _ Left ->
            True

        Dragging _ _ Right ->
            True

        Dragging _ _ Up ->
            True

        Dragging _ _ Down ->
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


isSeed : Type -> Bool
isSeed tileType =
    case tileType of
        Seed _ ->
            True

        _ ->
            False


isBurst : Type -> Bool
isBurst tileType =
    case tileType of
        Burst _ ->
            True

        _ ->
            False


isCollectible : Type -> Bool
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


growLeavingBurstToSeed : SeedType -> State -> State
growLeavingBurstToSeed seedType tileState =
    case tileState of
        Leaving (Burst (Just SeedPod)) moveOrder_ ->
            Growing (Seed seedType) moveOrder_

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
        Growing (Seed seedType) _ ->
            Static (Seed seedType)

        x ->
            x


growSeedPod : SeedType -> State -> State
growSeedPod seedType tileState =
    case tileState of
        Growing SeedPod n ->
            Growing (Seed seedType) n

        x ->
            x


setDraggingBurstType : Type -> State -> State
setDraggingBurstType tileType tileState =
    case tileState of
        Dragging (Burst _) moveOrder_ bearing ->
            Dragging (Burst <| Just tileType) moveOrder_ bearing

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
            Static <| resetBurstType tile

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


resetBurstType : Type -> Type
resetBurstType tileType =
    case tileType of
        Burst _ ->
            Burst Nothing

        x ->
            x


getSeedType : Type -> Maybe SeedType
getSeedType tileType =
    case tileType of
        Seed seedType ->
            Just seedType

        _ ->
            Nothing



-- Helpers


map : a -> (Type -> a) -> State -> a
map default fn =
    getType
        >> Maybe.map fn
        >> Maybe.withDefault default


getType : State -> Maybe Type
getType tileState =
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

        Empty ->
            Nothing


hash : Type -> String
hash tileType =
    case tileType of
        Rain ->
            "Rain"

        Sun ->
            "Sun"

        SeedPod ->
            "SeedPod"

        Seed seedType ->
            seedName seedType

        Burst tile ->
            hashBurst tile


hashBurst : Maybe Type -> String
hashBurst =
    Maybe.map (\tile -> "Burst" ++ hash tile) >> Maybe.withDefault "BurstEmpty"


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
