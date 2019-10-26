module Level.Setting.Start exposing
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

import Board.Block as Block
import Board.Coord as Coord exposing (Coord)
import Board.Move as Move exposing (Move)
import Board.Tile as Tile exposing (Tile(..))
import Seed exposing (Seed)



-- Tile


type Tile
    = Tile Coord Tile.Tile


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
move (Tile coord tile) =
    Move.move coord <| Block.static tile



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
        Coord.productXY
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
    Tile (toCoord x y) (Tile.Burst Nothing)


sun : Int -> Int -> Tile
sun x y =
    Tile (toCoord x y) Sun


rain : Int -> Int -> Tile
rain x y =
    Tile (toCoord x y) Rain


sunflower : Int -> Int -> Tile
sunflower =
    seed Seed.Sunflower


seed : Seed -> Int -> Int -> Tile
seed seed_ x y =
    Tile (toCoord x y) (Seed seed_)



-- Helpers


adjustX : Int -> Tile -> Tile
adjustX n (Tile coord tileType) =
    Tile (Coord.translateX n coord) tileType


adjustY : Int -> Tile -> Tile
adjustY n (Tile coord tileType) =
    Tile (Coord.translateY n coord) tileType


toCoord : Int -> Int -> Coord
toCoord x y =
    Coord.fromXY (x - 1) (y - 1)
