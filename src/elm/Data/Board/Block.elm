module Data.Board.Block exposing (..)

import Data.Board.Tile exposing (TileType, SeedType)
import Data.Board.TileState as TileState exposing (TileState(..), MoveOrder, MoveBearing)


type Block
    = Wall WallColor
    | Space TileState


type alias WallColor =
    String


growingOrder : Block -> Int
growingOrder =
    foldBlock TileState.growingOrder 0


leavingOrder : Block -> Int
leavingOrder =
    foldBlock TileState.leavingOrder 0


isLeaving : Block -> Bool
isLeaving =
    foldBlock TileState.isLeaving False


isDragging : Block -> Bool
isDragging =
    foldBlock TileState.isDragging False


isGrowing : Block -> Bool
isGrowing =
    foldBlock TileState.isGrowing False


isFalling : Block -> Bool
isFalling =
    foldBlock TileState.isFalling False


hasLine : Block -> Bool
hasLine =
    foldBlock TileState.hasLine False


moveOrder : Block -> Int
moveOrder =
    foldBlock TileState.moveOrder 0


isCurrentMove : Block -> Bool
isCurrentMove =
    foldBlock TileState.isCurrentMove False


setToDragging : MoveOrder -> Block -> Block
setToDragging moveOrder =
    mapBlock <| TileState.setToDragging moveOrder


setStaticToFirstMove : Block -> Block
setStaticToFirstMove =
    mapBlock TileState.setStaticToFirstMove


addBearing : MoveBearing -> Block -> Block
addBearing moveBearing =
    mapBlock <| TileState.addBearing moveBearing


setGrowingToStatic : Block -> Block
setGrowingToStatic =
    mapBlock TileState.setGrowingToStatic


growSeedPod : SeedType -> Block -> Block
growSeedPod seedType =
    mapBlock (TileState.growSeedPod seedType)


setToFalling : Int -> Block -> Block
setToFalling fallingDistance =
    mapBlock <| TileState.setToFalling fallingDistance


setEnteringToStatic : Block -> Block
setEnteringToStatic =
    mapBlock TileState.setEnteringToSatic


setFallingToStatic : Block -> Block
setFallingToStatic =
    mapBlock TileState.setFallingToStatic


setLeavingToEmpty : Block -> Block
setLeavingToEmpty =
    mapBlock TileState.setLeavingToEmpty


setDraggingToGrowing : Block -> Block
setDraggingToGrowing =
    mapBlock TileState.setDraggingToGrowing


setToLeaving : Block -> Block
setToLeaving =
    mapBlock TileState.setToLeaving


getTileType : Block -> Maybe TileType
getTileType =
    foldBlock TileState.getTileType Nothing


getTileState : Block -> TileState
getTileState =
    foldBlock identity Empty


isWall : Block -> Bool
isWall block =
    case block of
        Wall _ ->
            True

        _ ->
            False


mapBlock : (TileState -> TileState) -> Block -> Block
mapBlock fn block =
    case block of
        Space tileState ->
            Space <| fn tileState

        wall ->
            wall


foldBlock : (TileState -> a) -> a -> Block -> a
foldBlock fn default block =
    case block of
        Wall _ ->
            default

        Space tileState ->
            fn tileState
