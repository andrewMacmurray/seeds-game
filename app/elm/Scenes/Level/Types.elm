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
    , boardScale : BoardScale
    , scoreIconSize : Int
    , tileSize : TileSize
    , topBarHeight : Int
    , exitSequenceTriggered : Bool
    , mouse : Mouse.Position
    , window : Window.Size
    }


type Msg
    = InitTiles (List ( WallColor, Coord )) (List TileType)
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
    | InsertGrowingSeeds SeedType
    | ResetGrowingSeeds
    | GenerateEnteringTiles
    | InsertEnteringTiles (List TileType)
    | ResetEntering
    | ShiftBoard
    | ResetMove


type alias Scores =
    Dict String Score


type alias Score =
    { target : Int
    , current : Int
    }


type alias BoardScale =
    { x : Int
    , y : Int
    }


type alias HasBoard a =
    { a | board : Board }


type alias BoardConfig a =
    { a
        | board : Board
        , boardScale : BoardScale
        , tileSize : TileSize
    }


type alias TileConfig a =
    { a
        | moveShape : Maybe MoveShape
        , tileSize : TileSize
        , seedType : SeedType
        , window : Window.Size
        , boardScale : BoardScale
        , topBarHeight : Int
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
