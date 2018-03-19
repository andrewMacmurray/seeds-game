module Data2.Level.Settings exposing (..)

import Data2.Tile exposing (TileType)


type alias BoardDimensions =
    { x : Int
    , y : Int
    }


type alias TileSetting =
    { tileType : TileType
    , probability : Probability
    , targetScore : Maybe TargetScore
    }


type TargetScore
    = TargetScore Int


type Probability
    = Probability Int
