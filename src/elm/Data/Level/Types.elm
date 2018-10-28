module Data.Level.Types exposing
    ( Probability(..)
    , TargetScore(..)
    , TileSetting
    )

import Css.Color exposing (Color)
import Data.Board.Types exposing (BoardDimensions, Coord, SeedType, TileType)
import Dict exposing (Dict)


type alias TileSetting =
    { tileType : TileType
    , probability : Probability
    , targetScore : Maybe TargetScore
    }


type TargetScore
    = TargetScore Int


type Probability
    = Probability Int
