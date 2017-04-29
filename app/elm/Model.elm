module Model exposing (..)

import Dict exposing (..)


type alias Model =
    { board : Board
    , isDragging : Bool
    , currentMove : Maybe Move
    , boardSettings : BoardSettings
    , tileSettings : TileSettings
    }


type alias Move =
    List ( Coord, Tile )


type alias TileSettings =
    { sizeY : Int
    , sizeX : Int
    }


type alias BoardSettings =
    { sizeY : Int
    , sizeX : Int
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
    | StopMove
    | StartMove ( Coord, Tile )
    | CheckMove ( Coord, Tile )
