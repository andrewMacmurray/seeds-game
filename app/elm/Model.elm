module Model exposing (..)

import Dict exposing (..)
import Window


type alias Model =
    { board : Board
    , isDragging : Bool
    , currentMove : List Move
    , boardSettings : BoardSettings
    , tileSettings : TileSettings
    , window : Window.Size
    }


type alias TileSettings =
    { sizeY : Float
    , sizeX : Float
    }


type alias BoardSettings =
    { sizeY : Int
    , sizeX : Int
    }


type alias Move =
    ( Coord, TileState )


type alias Coord =
    ( Y, X )


type alias Y =
    Int


type alias X =
    Int


type alias LeavingOrder =
    Int


type alias FallingDistance =
    Int


type alias GrowingOrder =
    Int


type alias Board =
    Dict Coord TileState


type TileState
    = Static TileType
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


type Msg
    = InitTiles (List TileType)
    | AddTiles (List TileType)
    | StopMove
    | StopMoveSequence (List ( Float, Msg ))
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
    | WindowSize Window.Size
