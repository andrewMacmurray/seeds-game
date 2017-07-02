module Model exposing (..)

import Dict exposing (Dict)
import Window


type alias Model =
    { board : Board
    , scores : Scores
    , isDragging : Bool
    , moveShape : Maybe MoveShape
    , boardSettings : BoardSettings
    , tileSettings : TileSettings
    , topBarHeight : Int
    , window : Window.Size
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
    ( Coord, TileState )


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
    Dict Coord TileState


type MoveBearing
    = Head
    | Left
    | Right
    | Up
    | Down


type TileState
    = Static TileType
    | Dragging TileType MoveOrder MoveBearing
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
    | WindowSize Window.Size


type alias Style =
    ( String, String )
