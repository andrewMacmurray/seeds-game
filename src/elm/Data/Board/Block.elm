module Data.Board.Block exposing
    ( addBearing
    , fold
    , getTileState
    , getTileType
    , growSeedPod
    , growingOrder
    , hasLine
    , isCurrentMove
    , isDragging
    , isFalling
    , isGrowing
    , isLeaving
    , isWall
    , leavingOrder
    , map
    , moveOrder
    , setDraggingToGrowing
    , setEnteringToStatic
    , setFallingToStatic
    , setGrowingToStatic
    , setLeavingToEmpty
    , setStaticToFirstMove
    , setToDragging
    , setToFalling
    , setToLeaving
    )

import Data.Board.Tile as Tile
import Data.Board.Types exposing (..)


growingOrder : Block -> Int
growingOrder =
    fold Tile.growingOrder 0


leavingOrder : Block -> Int
leavingOrder =
    fold Tile.leavingOrder 0


isLeaving : Block -> Bool
isLeaving =
    fold Tile.isLeaving False


isDragging : Block -> Bool
isDragging =
    fold Tile.isDragging False


isGrowing : Block -> Bool
isGrowing =
    fold Tile.isGrowing False


isFalling : Block -> Bool
isFalling =
    fold Tile.isFalling False


hasLine : Block -> Bool
hasLine =
    fold Tile.hasLine False


moveOrder : Block -> Int
moveOrder =
    fold Tile.moveOrder 0


isCurrentMove : Block -> Bool
isCurrentMove =
    fold Tile.isCurrentMove False


setToDragging : MoveOrder -> Block -> Block
setToDragging moveOrder_ =
    map <| Tile.setToDragging moveOrder_


setStaticToFirstMove : Block -> Block
setStaticToFirstMove =
    map Tile.setStaticToFirstMove


addBearing : MoveBearing -> Block -> Block
addBearing moveBearing =
    map <| Tile.addBearing moveBearing


setGrowingToStatic : Block -> Block
setGrowingToStatic =
    map Tile.setGrowingToStatic


growSeedPod : SeedType -> Block -> Block
growSeedPod seedType =
    map (Tile.growSeedPod seedType)


setToFalling : Int -> Block -> Block
setToFalling fallingDistance =
    map <| Tile.setToFalling fallingDistance


setEnteringToStatic : Block -> Block
setEnteringToStatic =
    map Tile.setEnteringToSatic


setFallingToStatic : Block -> Block
setFallingToStatic =
    map Tile.setFallingToStatic


setLeavingToEmpty : Block -> Block
setLeavingToEmpty =
    map Tile.setLeavingToEmpty


setDraggingToGrowing : Block -> Block
setDraggingToGrowing =
    map Tile.setDraggingToGrowing


setToLeaving : Block -> Block
setToLeaving =
    map Tile.setToLeaving


getTileType : Block -> Maybe TileType
getTileType =
    fold Tile.getTileType Nothing


getTileState : Block -> TileState
getTileState =
    fold identity Empty


isWall : Block -> Bool
isWall block =
    case block of
        Wall _ ->
            True

        _ ->
            False


map : (TileState -> TileState) -> Block -> Block
map fn block =
    case block of
        Space tileState ->
            Space <| fn tileState

        wall ->
            wall


fold : (TileState -> a) -> a -> Block -> a
fold fn default block =
    case block of
        Wall _ ->
            default

        Space tileState ->
            fn tileState
