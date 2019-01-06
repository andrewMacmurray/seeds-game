module Data.Board.Block exposing
    ( addBearing
    , fold
    , getTileState
    , getTileType
    , growSeedPod
    , growingOrder
    , hasLine
    , isBurst
    , isCurrentMove
    , isDragging
    , isFalling
    , isGrowing
    , isLeaving
    , isReleasing
    , isWall
    , leavingOrder
    , map
    , moveOrder
    , removeBearing
    , resetDraggingBurstType
    , setDraggingBurstType
    , setDraggingToGrowing
    , setDraggingToReleasing
    , setDraggingToStatic
    , setEnteringToStatic
    , setFallingToStatic
    , setGrowingToStatic
    , setLeavingToEmpty
    , setReleasingToStatic
    , setStaticToFirstMove
    , setToDragging
    , setToFalling
    , setToLeaving
    , static
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


isReleasing : Block -> Bool
isReleasing =
    fold Tile.isReleasing False


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
setToDragging =
    map << Tile.setToDragging


removeBearing : Block -> Block
removeBearing =
    map Tile.removeBearing


setStaticToFirstMove : Block -> Block
setStaticToFirstMove =
    map Tile.setStaticToFirstMove


addBearing : MoveBearing -> Block -> Block
addBearing =
    map << Tile.addBearing


setDraggingBurstType : TileType -> Block -> Block
setDraggingBurstType =
    map << Tile.setDraggingBurstType


resetDraggingBurstType : Block -> Block
resetDraggingBurstType =
    map Tile.resetDraggingBurstType


setGrowingToStatic : Block -> Block
setGrowingToStatic =
    map Tile.setGrowingToStatic


growSeedPod : SeedType -> Block -> Block
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


setReleasingToStatic : Block -> Block
setReleasingToStatic =
    map Tile.setReleasingToStatic


setLeavingToEmpty : Block -> Block
setLeavingToEmpty =
    map Tile.setLeavingToEmpty


setDraggingToStatic : Block -> Block
setDraggingToStatic =
    map Tile.setDraggingToStatic


setDraggingToGrowing : Block -> Block
setDraggingToGrowing =
    map Tile.setDraggingToGrowing


setDraggingToReleasing : Block -> Block
setDraggingToReleasing =
    map Tile.setDraggingToReleasing


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


isBurst : Block -> Bool
isBurst =
    let
        burst =
            Tile.getTileType >> Maybe.map Tile.isBurst >> Maybe.withDefault False
    in
    fold burst False


static : TileType -> Block
static =
    Static >> Space


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
