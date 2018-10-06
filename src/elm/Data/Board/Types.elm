module Data.Board.Types exposing
    ( Block(..)
    , Board
    , BoardConfig
    , BoardDimensions
    , Coord
    , FallingDistance
    , GrowingOrder
    , HasBoard
    , LeavingOrder
    , Move
    , MoveBearing(..)
    , MoveOrder
    , MoveShape(..)
    , Score
    , Scores
    , SeedType(..)
    , TileConfig
    , TileState(..)
    , TileType(..)
    , X
    , Y
    )

import Config.Color exposing (Color)
import Data.Window as Window
import Dict exposing (Dict)



-- Extensible Records for working with a Board


type alias HasBoard a =
    { a | board : Board }


type alias BoardConfig a =
    { a
        | board : Board
        , boardDimensions : BoardDimensions
    }


type alias TileConfig a =
    { a
        | moveShape : Maybe MoveShape
        , window : Window.Size
        , boardDimensions : BoardDimensions
    }


type alias BoardDimensions =
    { x : Int
    , y : Int
    }



-- Keeps Track of current Scores for each resource


type alias Scores =
    Dict String Score


type alias Score =
    { target : Int
    , current : Int
    }



-- Core Board Type


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
