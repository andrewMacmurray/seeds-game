module Scenes.Level.Model exposing (..)

import Dict exposing (Dict)


type alias Model =
    { board : Board
    , scores : Scores
    , isDragging : Bool
    , moveShape : Maybe MoveShape
    , boardSettings : BoardSettings
    , tileSettings : TileSettings
    , topBarHeight : Int
    }


type alias Scores =
    Dict String Int


type alias TileSettings =
    { sizeY : Float
    , sizeX : Float
    }


type alias BoardSettings =
    { sizeY : Int
    , sizeX : Int
    }


type alias Move =
    ( Coord, Block )


type MoveShape
    = Square
    | Line


type alias Coord =
    ( Y, X )


type alias Y =
    Int


type alias X =
    Int


type alias MoveOrder =
    Int


type alias LeavingOrder =
    Int


type alias FallingDistance =
    Int


type alias GrowingOrder =
    Int


type alias Board =
    Dict Coord Block


type MoveBearing
    = Head
    | Left
    | Right
    | Up
    | Down


type Block
    = Wall
    | Space TileState


type TileState
    = Static TileType
    | Dragging TileType MoveOrder MoveBearing MoveShape
    | Leaving TileType LeavingOrder
    | Falling TileType FallingDistance
    | Entering TileType
    | Growing TileType GrowingOrder
    | Empty


type TileType
    = Rain
    | Sun
    | SeedPod
    | Seed


type SeedType
    = Sunflower
    | Foxglove
    | Lupin
    | Marigold
    | Rose


type Msg
    = InitTiles (List Coord) (List TileType)
    | AddTiles (List TileType)
    | SquareMove
    | StopMove MoveShape
    | StartMove Move
    | CheckMove Move
    | SetLeavingTiles
    | SetFallingTiles
    | SetGrowingSeedPods
    | GrowPodsToSeeds
    | ResetGrowingSeeds
    | MakeNewTiles
    | ResetEntering
    | ShiftBoard
    | ResetMove
