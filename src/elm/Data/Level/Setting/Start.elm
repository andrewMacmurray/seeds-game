module Data.Level.Setting.Start exposing
    ( Direction(..)
    , Facing(..)
    , Tile
    , burst
    , corner
    , line
    , move
    , rain
    , rectangle
    , seed
    , square
    , sun
    , sunflower
    )

import Data.Board.Block as Block
import Data.Board.Coord as Coord exposing (Coord)
import Data.Board.Move as Move exposing (Move)
import Data.Board.Tile as Tile exposing (SeedType(..), Type(..))



-- Tile


type Tile
    = Tile Coord Tile.Type


type Direction
    = Vertical
    | Horizontal


type Facing
    = TopLeft
    | BottomLeft
    | TopRight
    | BottomRight



-- To Move


move : Tile -> Move
move (Tile coord tileType) =
    Move.move coord <| Block.static tileType



-- Tiles


square : Tile -> { size : Int } -> List Tile
square tile { size } =
    rectangle tile { x = size, y = size }


line : Tile -> { length : Int, direction : Direction } -> List Tile
line tile { length, direction } =
    case direction of
        Vertical ->
            rectangle tile { x = 1, y = length }

        Horizontal ->
            rectangle tile { x = length, y = 1 }


rectangle : Tile -> { x : Int, y : Int } -> List Tile
rectangle (Tile coord tileType) opts =
    let
        x =
            Coord.x coord

        y =
            Coord.y coord

        toTiles c =
            Tile c tileType
    in
    List.map toTiles <|
        Coord.rangeXY
            (List.range x (x + opts.x - 1))
            (List.range y (y + opts.y - 1))


corner : Tile -> { size : Int, facing : Facing } -> List Tile
corner tile { size, facing } =
    let
        flippedY =
            adjustY (-size + 1) tile

        flippedX =
            adjustX (-size + 1) tile

        vertical =
            { length = size, direction = Vertical }

        horizontal =
            { length = size, direction = Horizontal }
    in
    case facing of
        BottomRight ->
            List.concat [ line tile vertical, line tile horizontal ]

        BottomLeft ->
            List.concat [ line tile vertical, line flippedX horizontal ]

        TopRight ->
            List.concat [ line flippedY vertical, line tile horizontal ]

        TopLeft ->
            List.concat [ line flippedY vertical, line flippedX horizontal ]


burst : Int -> Int -> Tile
burst x y =
    Tile (toCoord x y) (Burst Nothing)


sun : Int -> Int -> Tile
sun x y =
    Tile (toCoord x y) Sun


rain : Int -> Int -> Tile
rain x y =
    Tile (toCoord x y) Rain


sunflower : Int -> Int -> Tile
sunflower =
    seed Sunflower


seed : Tile.SeedType -> Int -> Int -> Tile
seed seedType x y =
    Tile (toCoord x y) (Seed seedType)



-- Helpers


adjustX : Int -> Tile -> Tile
adjustX n (Tile coord tileType) =
    Tile (Coord.fromXY (n + Coord.x coord) (Coord.y coord)) tileType


adjustY : Int -> Tile -> Tile
adjustY n (Tile coord tileType) =
    Tile (Coord.fromXY (Coord.x coord) (Coord.y coord + n)) tileType


toCoord : Int -> Int -> Coord
toCoord x y =
    Coord.fromXY (x - 1) (y - 1)
