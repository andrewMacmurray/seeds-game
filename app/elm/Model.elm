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
    ( Y, X )


type alias Y =
    Int


type alias X =
    Int


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
