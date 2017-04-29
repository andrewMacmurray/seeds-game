module Types exposing (..)

import Dict exposing (..)


type alias Model =
    { board : Board
    , boardSettings : BoardSettings
    , tileSettings : TileSettings
    }


type alias TileSettings =
    { sizeY : Int
    , sizeX : Int
    }


type alias BoardSettings =
    { sizeX : Int
    , sizeY : Int
    }


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
