module Data.Board.Block exposing
    ( Block(..)
    , addBearing
    , clearBearing
    , clearBurstType
    , empty
    , fold
    , getTileState
    , growLeavingBurstToSeed
    , growSeedPod
    , growingOrder
    , hasLine
    , isBurst
    , isCollectible
    , isCurrentMove
    , isDragging
    , isEmpty
    , isFalling
    , isGrowing
    , isLeaving
    , isWall
    , leavingOrder
    , map
    , moveOrder
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
    , static
    , tileType
    )

import Css.Color as Css
import Data.Board.Tile as Tile



-- Block


type Block
    = Wall Css.Color
    | Space Tile.State



-- Construct


static : Tile.Type -> Block
static =
    Tile.Static >> Space


empty : Block
empty =
    Space Tile.Empty



-- Query


growingOrder : Block -> Int
growingOrder =
    fold Tile.growingOrder 0


leavingOrder : Block -> Int
leavingOrder =
    fold Tile.leavingOrder 0


isEmpty : Block -> Bool
isEmpty =
    fold Tile.isEmpty False


isLeaving : Block -> Bool
isLeaving =
    fold Tile.isLeaving False


isDragging : Block -> Bool
isDragging =
    fold Tile.isDragging False


isFalling : Block -> Bool
isFalling =
    fold Tile.isFalling False


isGrowing : Block -> Bool
isGrowing =
    fold Tile.isGrowing False


hasLine : Block -> Bool
hasLine =
    fold Tile.hasLine False


moveOrder : Block -> Int
moveOrder =
    fold Tile.moveOrder 0


isCurrentMove : Block -> Bool
isCurrentMove =
    fold Tile.isCurrentMove False


tileType : Block -> Maybe Tile.Type
tileType =
    fold Tile.getType Nothing


getTileState : Block -> Tile.State
getTileState =
    fold identity Tile.Empty


isWall : Block -> Bool
isWall block =
    case block of
        Wall _ ->
            True

        _ ->
            False


isCollectible : Block -> Bool
isCollectible =
    fold (matchTile Tile.isCollectible) False


isBurst : Block -> Bool
isBurst =
    fold (matchTile Tile.isBurst) False



-- Update


setToDragging : Tile.MoveOrder -> Block -> Block
setToDragging =
    map << Tile.setToDragging


growLeavingBurstToSeed : Tile.SeedType -> Block -> Block
growLeavingBurstToSeed =
    map << Tile.growLeavingBurstToSeed


setToActive : Block -> Block
setToActive =
    map Tile.setToActive


setActiveToStatic : Block -> Block
setActiveToStatic =
    map Tile.setActiveToStatic


clearBearing : Block -> Block
clearBearing =
    map Tile.removeBearing


setStaticToFirstMove : Block -> Block
setStaticToFirstMove =
    map Tile.setStaticToFirstMove


addBearing : Tile.Bearing -> Block -> Block
addBearing =
    map << Tile.addBearing


setDraggingBurstType : Tile.Type -> Block -> Block
setDraggingBurstType =
    map << Tile.setDraggingBurstType


clearBurstType : Block -> Block
clearBurstType =
    map Tile.clearBurstType


setGrowingToStatic : Block -> Block
setGrowingToStatic =
    map Tile.setGrowingToStatic


growSeedPod : Tile.SeedType -> Block -> Block
growSeedPod =
    map << Tile.growSeedPod


setToFalling : Int -> Block -> Block
setToFalling =
    map << Tile.setToFalling


setEnteringToStatic : Block -> Block
setEnteringToStatic =
    map Tile.setEnteringToStatic


setFallingToStatic : Block -> Block
setFallingToStatic =
    map Tile.setFallingToStatic


setLeavingToEmpty : Block -> Block
setLeavingToEmpty =
    map Tile.setLeavingToEmpty


setDraggingToStatic : Block -> Block
setDraggingToStatic =
    map Tile.setDraggingToStatic


setDraggingToGrowing : Block -> Block
setDraggingToGrowing =
    map Tile.setDraggingToGrowing


setDraggingToLeaving : Block -> Block
setDraggingToLeaving =
    map Tile.setDraggingToLeaving



-- Helpers


matchTile : (Tile.Type -> Bool) -> Tile.State -> Bool
matchTile f =
    Tile.getType
        >> Maybe.map f
        >> Maybe.withDefault False


map : (Tile.State -> Tile.State) -> Block -> Block
map f block =
    case block of
        Space tileState ->
            Space <| f tileState

        wall ->
            wall


fold : (Tile.State -> a) -> a -> Block -> a
fold f default block =
    case block of
        Wall _ ->
            default

        Space tileState ->
            f tileState
