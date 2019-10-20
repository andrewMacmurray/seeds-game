module Data.Level.Setting.Start exposing
    ( Direction(..)
    , Facing(..)
    , Tile
    , burst
    , cornerOf
    , lineOf
    , move
    , rain
    , seed
    , squareOf
    , sun
    )

import Data.Board.Block as Block
import Data.Board.Coord as Coord
import Data.Board.Move as Move
import Data.Board.Types exposing (Coord, Move, SeedType(..), TileType(..))



-- Tile


type Tile
    = Tile Coord TileType


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


squareOf : Tile -> { size : Int } -> List Tile
squareOf (Tile c tt) { size } =
    toTiles tt <| Coord.square { size = size, x = Coord.x c, y = Coord.y c }


lineOf : Tile -> { length : Int, direction : Direction } -> List Tile
lineOf (Tile coord tileType) { length, direction } =
    let
        x =
            Coord.x coord

        y =
            Coord.y coord
    in
    case direction of
        Vertical ->
            toTiles tileType <| Coord.rangeXY [ x ] (List.range y (y + length - 1))

        Horizontal ->
            toTiles tileType <| Coord.rangeXY (List.range x (x + length - 1)) [ y ]


toTiles : TileType -> List Coord -> List Tile
toTiles tileType =
    List.map (\coord -> Tile coord tileType)


cornerOf : Tile -> { size : Int, facing : Facing } -> List Tile
cornerOf tile { size, facing } =
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
            List.concat [ lineOf tile vertical, lineOf tile horizontal ]

        BottomLeft ->
            List.concat [ lineOf tile vertical, lineOf flippedX horizontal ]

        TopRight ->
            List.concat [ lineOf flippedY vertical, lineOf tile horizontal ]

        TopLeft ->
            List.concat [ lineOf flippedY vertical, lineOf flippedX horizontal ]


burst : Int -> Int -> Tile
burst x y =
    Tile (toCoord x y) (Burst Nothing)


sun : Int -> Int -> Tile
sun x y =
    Tile (toCoord x y) Sun


rain : Int -> Int -> Tile
rain x y =
    Tile (toCoord x y) Rain


seed : SeedType -> Int -> Int -> Tile
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
