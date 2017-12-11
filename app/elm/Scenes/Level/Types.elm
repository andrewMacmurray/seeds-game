module Scenes.Level.Types exposing (..)

import Dict exposing (Dict)
import Mouse
import Window


type alias Model =
    { board : Board
    , scores : Scores
    , isDragging : Bool
    , moveShape : Maybe MoveShape
    , seedType : SeedType
    , tileSettings : List TileSetting
    , boardScale : Int
    , scoreIconSize : Int
    , tileSize : TileSize
    , topBarHeight : Int
    , exitSequenceTriggered : Bool
    , mouse : Mouse.Position
    , window : Window.Size
    }


type Msg
    = InitTiles (List Coord) (List TileType)
    | AddTiles (List TileType)
    | SquareMove
    | StopMove MoveShape
    | StartMove Move
    | CheckMove Move
    | CheckLevelComplete
    | ExitLevel
    | SetLeavingTiles
    | SetFallingTiles
    | SetGrowingSeedPods
    | GrowPodsToSeeds
    | ResetGrowingSeeds
    | MakeNewTiles
    | ResetEntering
    | ShiftBoard
    | ResetMove


type alias Scores =
    Dict String Score


type alias Score =
    { target : Int
    , current : Int
    }


type alias BoardConfig a =
    { a
        | board : Board
        , boardScale : Int
        , tileSize : TileSize
    }


type alias HasBoard a =
    { a | board : Board }


type alias TileConfig a =
    { a
        | moveShape : Maybe MoveShape
        , tileSize : TileSize
        , seedType : SeedType
    }


type alias TileSize =
    { y : Float
    , x : Float
    }


type alias TileSetting =
    { tileType : TileType
    , probability : Int
    , targetScore : Maybe Int
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
    | Releasing TileType
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
    | GreyedOut
