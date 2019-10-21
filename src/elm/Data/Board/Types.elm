module Data.Board.Types exposing
    ( Board
    , BoardDimensions
    )

import Data.Board.Block exposing (Block)
import Data.Board.Coord exposing (Coord)
import Dict exposing (Dict)



-- Core Board Type


type alias BoardDimensions =
    { x : Int
    , y : Int
    }


type alias Board =
    Dict Coord Block
