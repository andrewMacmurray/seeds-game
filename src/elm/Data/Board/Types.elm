module Data.Board.Types exposing (..)

import Dict exposing (Dict)


type alias Board =
    Dict Coord Block


type alias HasBoard a =
    { a | board : Board }


type alias Move =
    ( Coord, Block )


type alias Coord =
    ( Y, X )


type alias Y =
    Int


type alias X =
    Int


type Block
    = Wall WallColor
    | Space TileState


type alias WallColor =
    String


type TileState
    = Static TileType
    | Dragging TileType MoveOrder MoveBearing MoveShape
    | Leaving TileType LeavingOrder
    | Falling TileType FallingDistance
    | Entering TileType
    | Growing TileType GrowingOrder
    | Empty


type MoveBearing
    = Head
    | Left
    | Right
    | Up
    | Down


type MoveShape
    = Square
    | Line


type alias MoveOrder =
    Int


type alias LeavingOrder =
    Int


type alias FallingDistance =
    Int


type alias GrowingOrder =
    Int


type TileType
    = Rain
    | Sun
    | SeedPod
    | Seed SeedType


type SeedType
    = Sunflower
    | Foxglove
    | Lupin
    | Marigold
    | Rose
    | GreyedOut
