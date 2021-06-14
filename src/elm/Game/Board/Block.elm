module Game.Board.Block exposing
    ( Block(..)
    , addBearing
    , clearBearing
    , clearBurstType
    , empty
    , entering
    , foldTile
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
    , isWall
    , leavingOrder
    , moveOrder
    , releaseDraggingSeeds
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
    , static
    , tile
    , tileState
    )

import Element
import Game.Board.Tile as Tile exposing (Tile)
import Seed exposing (Seed)



-- Block


type Block
    = Wall Element.Color
    | Space Tile.State



-- Construct


static : Tile -> Block
static =
    Tile.Static >> Space


empty : Block
empty =
    Space Tile.Empty


entering : Tile -> Block
entering =
    Tile.Entering >> Space



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


isReleasing : Block -> Bool
isReleasing =
    fold Tile.isReleasing False


isFalling : Block -> Bool
isFalling =
    fold Tile.isFalling False


isGrowing : Block -> Bool
isGrowing =
    fold Tile.isGrowing False


moveOrder : Block -> Int
moveOrder =
    fold Tile.moveOrder 0


isCurrentMove : Block -> Bool
isCurrentMove =
    fold Tile.isCurrentMove False


tile : Block -> Maybe Tile
tile =
    fold Tile.get Nothing


tileState : Block -> Tile.State
tileState =
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


isSeed : Block -> Bool
isSeed =
    fold (matchTile Tile.isSeed) False



-- Update


setToDragging : Tile.MoveOrder -> Block -> Block
setToDragging =
    map << Tile.setToDragging


growLeavingBurstToSeed : Seed -> Block -> Block
growLeavingBurstToSeed =
    map << Tile.growLeavingBurstToSeed


releaseDraggingSeeds : Block -> Block
releaseDraggingSeeds =
    map Tile.releaseDraggingSeeds


setReleasingToStatic : Block -> Block
setReleasingToStatic =
    map Tile.setReleasingToStatic


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


setDraggingBurstType : Tile -> Block -> Block
setDraggingBurstType =
    map << Tile.setDraggingBurstType


clearBurstType : Block -> Block
clearBurstType =
    map Tile.clearBurstType


setGrowingToStatic : Block -> Block
setGrowingToStatic =
    map Tile.setGrowingToStatic


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


matchTile : (Tile -> Bool) -> Tile.State -> Bool
matchTile f =
    Tile.get
        >> Maybe.map f
        >> Maybe.withDefault False


map : (Tile.State -> Tile.State) -> Block -> Block
map f block =
    case block of
        Space tileState_ ->
            Space <| f tileState_

        wall ->
            wall


foldTile : (Tile -> a) -> a -> Block -> a
foldTile f default =
    fold (Tile.map default f) default


fold : (Tile.State -> a) -> a -> Block -> a
fold f default block =
    case block of
        Wall _ ->
            default

        Space tileState_ ->
            f tileState_
