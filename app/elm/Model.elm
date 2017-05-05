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
    ( Coord, TileState )


type alias Coord =
    ( Y, X )


type alias Y =
    Int


type alias X =
    Int


type alias LeavingOrder =
    Int


type alias Board =
    Dict Coord TileState


type TileState
    = Static Tile
    | Leaving Tile LeavingOrder
    | Empty


type Tile
    = Rain
    | Sun
    | SeedPod
    | Seed


type Msg
    = RandomTiles (List Tile)
    | StopMove
    | StartMove Move
    | CheckMove Move
