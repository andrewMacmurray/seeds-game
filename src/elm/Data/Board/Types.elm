module Data.Board.Types exposing
    ( Bearing(..)
    , Block(..)
    , Board
    , BoardDimensions
    , Coord
    , Distance
    , Move
    , MoveOrder
    , SeedType(..)
    , TileState(..)
    , TileType(..)
    , X
    , Y
    )

import Css.Color exposing (Color)
import Dict exposing (Dict)



-- Core Board Type


type alias BoardDimensions =
    { x : Int
    , y : Int
    }


type alias Board =
    Dict Coord Block


type alias Move =
    ( Coord, Block )


type alias Coord =
    ( Y, X )


type alias Y =
    Int


type alias X =
    Int


type Block
    = Wall Color
    | Space TileState


type TileState
    = Static TileType
    | Dragging TileType MoveOrder Bearing
    | Leaving TileType MoveOrder
    | Falling TileType Distance
    | Entering TileType
    | Growing TileType MoveOrder
    | Empty


type Bearing
    = Head
    | Left
    | Right
    | Up
    | Down


type alias Distance =
    Int


type alias MoveOrder =
    Int


type TileType
    = Rain
    | Sun
    | SeedPod
    | Seed SeedType
    | Burst (Maybe TileType)


type SeedType
    = Sunflower
    | Chrysanthemum
    | Cornflower
    | Lupin
    | Marigold
    | Rose
