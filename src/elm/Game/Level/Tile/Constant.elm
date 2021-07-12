module Game.Level.Tile.Constant exposing
    ( Direction(..)
    , Facing(..)
    , Tile
    , burst
    , chrysanthemum
    , corner
    , line
    , move
    , rain
    , rectangle
    , seedPod
    , square
    , sun
    , sunflower
    )

import Game.Board.Block as Block
import Game.Board.Coord as Coord exposing (Coord)
import Game.Board.Move as Move exposing (Move)
import Game.Board.Tile as Tile exposing (Tile(..))
import Seed exposing (Seed)
import Utils.List as List



-- Tile


type Tile
    = Tile Tile.Tile Coord


type Direction
    = Vertical
    | Horizontal
    | Diagonal Facing


type Facing
    = TopLeft
    | BottomLeft
    | TopRight
    | BottomRight



-- To Move


move : Tile -> Move
move (Tile tile coord) =
    Move.move coord (Block.static tile)



-- Tiles


square : Tile -> { size : Int } -> List Tile
square tile { size } =
    rectangle tile
        { x = size
        , y = size
        }


line : Tile -> { length : Int, direction : Direction } -> List Tile
line tile { length, direction } =
    case direction of
        Vertical ->
            rectangle tile { x = 1, y = length }

        Horizontal ->
            rectangle tile { x = length, y = 1 }

        Diagonal facing ->
            diagonal facing length tile


rectangle : Tile -> { x : Int, y : Int } -> List Tile
rectangle (Tile tileType coord) opts =
    let
        x =
            Coord.x coord

        y =
            Coord.y coord
    in
    List.map (Tile tileType)
        (Coord.productXY
            (List.range x (x + opts.x - 1))
            (List.range y (y + opts.y - 1))
        )


diagonal : Facing -> Int -> Tile -> List Tile
diagonal facing length (Tile tileType coord) =
    let
        toDiagonal xs ys =
            List.map2 Coord.fromXY xs ys
                |> List.map (Tile tileType)

        x =
            Coord.x coord

        y =
            Coord.y coord
    in
    case facing of
        BottomRight ->
            toDiagonal
                (List.range x length)
                (List.range y length)

        TopRight ->
            toDiagonal
                (List.range x length)
                (List.inverseRange y length)

        BottomLeft ->
            toDiagonal
                (List.inverseRange x length)
                (List.range y length)

        TopLeft ->
            toDiagonal
                (List.inverseRange x length)
                (List.inverseRange y length)


corner : Tile -> { size : Int, facing : Facing } -> List Tile
corner tile { size, facing } =
    let
        flippedY =
            moveDown (-size + 1) tile

        flippedX =
            moveRight (-size + 1) tile

        vertical =
            { length = size, direction = Vertical }

        horizontal =
            { length = size, direction = Horizontal }
    in
    case facing of
        BottomRight ->
            line tile vertical ++ line tile horizontal

        BottomLeft ->
            line tile vertical ++ line flippedX horizontal

        TopRight ->
            line flippedY vertical ++ line tile horizontal

        TopLeft ->
            line flippedY vertical ++ line flippedX horizontal


burst : Int -> Int -> Tile
burst x y =
    Tile (Tile.Burst Nothing) (toCoord x y)


sun : Int -> Int -> Tile
sun x y =
    Tile Sun (toCoord x y)


rain : Int -> Int -> Tile
rain x y =
    Tile Rain (toCoord x y)


seedPod : Int -> Int -> Tile
seedPod x y =
    Tile SeedPod (toCoord x y)


sunflower : Int -> Int -> Tile
sunflower =
    seed Seed.Sunflower


chrysanthemum : Int -> Int -> Tile
chrysanthemum =
    seed Seed.Chrysanthemum


seed : Seed -> Int -> Int -> Tile
seed seed_ x y =
    Tile (Seed seed_) (toCoord x y)



-- Helpers


moveRight : Int -> Tile -> Tile
moveRight n (Tile tileType coord) =
    Tile tileType (Coord.translateX n coord)


moveDown : Int -> Tile -> Tile
moveDown n (Tile tileType coord) =
    Tile tileType (Coord.translateY n coord)


toCoord : Int -> Int -> Coord
toCoord x y =
    Coord.fromXY (x - 1) (y - 1)
