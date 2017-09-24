module Data.Level.Board.Tile exposing (..)

import Data.Level.Board.Block as Block
import Data.Color exposing (darkBrown, gold, green, lightBlue, seedPodGradient)
import Helpers.Style exposing (background, backgroundColor, backgroundImage, emptyStyle, frameBackground, size, svgStyle)
import Model exposing (Style)
import Scenes.Level.Model exposing (..)


growingOrder : Block -> Int
growingOrder =
    Block.fold tileGrowingOrder 0


tileGrowingOrder : TileState -> Int
tileGrowingOrder tileState =
    case tileState of
        Growing _ order ->
            order

        _ ->
            0


leavingOrder : Block -> Int
leavingOrder =
    Block.fold tileLeavingOrder 0


tileLeavingOrder : TileState -> Int
tileLeavingOrder tileState =
    case tileState of
        Leaving _ order ->
            order

        _ ->
            0


isLeaving : Block -> Bool
isLeaving =
    Block.fold isLeavingTile False


isLeavingTile : TileState -> Bool
isLeavingTile tileState =
    case tileState of
        Leaving _ _ ->
            True

        _ ->
            False


isDragging : Block -> Bool
isDragging =
    Block.fold isDraggingTile False


isDraggingTile : TileState -> Bool
isDraggingTile tileState =
    case tileState of
        Dragging _ _ _ _ ->
            True

        _ ->
            False


isFalling : Block -> Bool
isFalling =
    Block.fold isFallingTile False


isFallingTile : TileState -> Bool
isFallingTile tileState =
    case tileState of
        Falling _ _ ->
            True

        _ ->
            False


moveOrder : Block -> Int
moveOrder =
    Block.fold moveOrderTile 0


moveOrderTile : TileState -> Int
moveOrderTile tileState =
    case tileState of
        Dragging _ moveOrder _ _ ->
            moveOrder

        _ ->
            0


isCurrentMove : Block -> Bool
isCurrentMove =
    Block.fold isCurrentMoveTile False


isCurrentMoveTile : TileState -> Bool
isCurrentMoveTile tileState =
    case tileState of
        Dragging _ _ Head _ ->
            True

        _ ->
            False


setToDragging : MoveOrder -> Block -> Block
setToDragging moveOrder =
    Block.map <| setToDraggingTile moveOrder


setToDraggingTile : MoveOrder -> TileState -> TileState
setToDraggingTile moveOrder tileState =
    case tileState of
        Static tileType ->
            Dragging tileType moveOrder Head Line

        Dragging tileType _ bearing _ ->
            Dragging tileType moveOrder bearing Square

        x ->
            x


setStaticToFirstMove : Block -> Block
setStaticToFirstMove =
    Block.map setStaticToFirstMoveTile


setStaticToFirstMoveTile : TileState -> TileState
setStaticToFirstMoveTile tileState =
    case tileState of
        Static tileType ->
            Dragging tileType 1 Head Line

        x ->
            x


addBearing : MoveBearing -> Block -> Block
addBearing moveBearing =
    Block.map <| addBearingTile moveBearing


addBearingTile : MoveBearing -> TileState -> TileState
addBearingTile moveBearing tileState =
    case tileState of
        Dragging tileType moveOrder _ moveShape ->
            Dragging tileType moveOrder moveBearing moveShape

        x ->
            x


setGrowingToStatic : Block -> Block
setGrowingToStatic =
    Block.map setGrowingToStaticTile


setGrowingToStaticTile : TileState -> TileState
setGrowingToStaticTile tileState =
    case tileState of
        Growing Seed _ ->
            Static Seed

        x ->
            x


growSeedPod : Block -> Block
growSeedPod =
    Block.map growSeedPodTile


growSeedPodTile : TileState -> TileState
growSeedPodTile tileState =
    case tileState of
        Growing SeedPod n ->
            Growing Seed n

        x ->
            x


setToFalling : Int -> Block -> Block
setToFalling fallingDistance =
    Block.map <| setToFallingTile fallingDistance


setToFallingTile : Int -> TileState -> TileState
setToFallingTile fallingDistance tileState =
    case tileState of
        Static tile ->
            Falling tile fallingDistance

        Falling tile _ ->
            Falling tile fallingDistance

        x ->
            x


setEnteringToStatic : Block -> Block
setEnteringToStatic =
    Block.map setEnteringToSaticTile


setEnteringToSaticTile : TileState -> TileState
setEnteringToSaticTile tileState =
    case tileState of
        Entering tile ->
            Static tile

        x ->
            x


setFallingToStatic : Block -> Block
setFallingToStatic =
    Block.map setFallingToStaticTile


setFallingToStaticTile : TileState -> TileState
setFallingToStaticTile tileState =
    case tileState of
        Falling tile _ ->
            Static tile

        x ->
            x


setLeavingToEmpty : Block -> Block
setLeavingToEmpty =
    Block.map setLeavingToEmptyTile


setLeavingToEmptyTile : TileState -> TileState
setLeavingToEmptyTile tileState =
    case tileState of
        Leaving _ _ ->
            Empty

        x ->
            x


setDraggingToGrowing : Block -> Block
setDraggingToGrowing =
    Block.map setDraggingToGrowingTile


setDraggingToGrowingTile : TileState -> TileState
setDraggingToGrowingTile tileState =
    case tileState of
        Dragging SeedPod order _ _ ->
            Growing SeedPod order

        x ->
            x


setToLeaving : Block -> Block
setToLeaving =
    Block.map setToLeavingTile


setToLeavingTile : TileState -> TileState
setToLeavingTile tileState =
    case tileState of
        Dragging Rain order _ _ ->
            Leaving Rain order

        Dragging Sun order _ _ ->
            Leaving Sun order

        Dragging Seed order _ _ ->
            Leaving Seed order

        x ->
            x


getTileType : Block -> Maybe TileType
getTileType =
    Block.fold getTileType_ Nothing


getTileType_ : TileState -> Maybe TileType
getTileType_ tileState =
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


tileColorMap : SeedType -> Block -> List Style
tileColorMap seedType =
    Block.fold (tileColorMap_ seedType) []


tileColorMap_ : SeedType -> TileState -> List Style
tileColorMap_ seedType =
    tileStyleMap <| tileColors seedType


tileSizeMap : Block -> List Style
tileSizeMap =
    Block.fold tileSizeMap_ []


tileSizeMap_ : TileState -> List Style
tileSizeMap_ =
    tileStyleMap tileSize


strokeColors : TileType -> String
strokeColors tile =
    case tile of
        Rain ->
            svgStyle "stroke" lightBlue

        Sun ->
            svgStyle "stroke" gold

        SeedPod ->
            svgStyle "stroke" green

        Seed ->
            svgStyle "stroke" darkBrown


tileColors : SeedType -> TileType -> List Style
tileColors seedType tile =
    case tile of
        Rain ->
            [ backgroundColor lightBlue ]

        Sun ->
            [ backgroundColor gold ]

        SeedPod ->
            [ background seedPodGradient ]

        Seed ->
            [ backgroundImage <| seedBackgrounds seedType ] ++ frameBackground


seedBackgrounds : SeedType -> String
seedBackgrounds seedType =
    case seedType of
        Sunflower ->
            "img/sunflower.svg"

        Foxglove ->
            "img/foxglove.svg"

        Lupin ->
            "img/lupin.svg"

        Rose ->
            "img/rose.svg"

        _ ->
            ""


tileSize : TileType -> List Style
tileSize tile =
    case tile of
        Rain ->
            size 18

        Sun ->
            size 18

        SeedPod ->
            size 26

        Seed ->
            size 35


tileClassMap : (TileType -> String) -> TileState -> String
tileClassMap =
    tileTypeMap ""


tileStyleMap : (TileType -> List Style) -> TileState -> List Style
tileStyleMap =
    tileTypeMap []


tileTypeMap : a -> (TileType -> a) -> TileState -> a
tileTypeMap default fn tileState =
    tileState
        |> getTileType_
        |> Maybe.map fn
        |> Maybe.withDefault default
