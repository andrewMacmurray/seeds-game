module Model exposing (..)

import Dict exposing (..)


type alias Model =
    { board : Board
    , isDragging : Bool
    , currentMove : List Move
    , boardSettings : BoardSettings
    , tileSettings : TileSettings
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
    ( Coord, Tile )


type alias Coord =
    ( Int, Int )


type alias Board =
    Dict Coord Tile


type Tile
    = Rain
    | Sun
    | SeedPod
    | Seed
    | Blank


type Msg
    = RandomTiles (List Tile)
    | StopMove
    | StartMove Move
    | CheckMove Move
