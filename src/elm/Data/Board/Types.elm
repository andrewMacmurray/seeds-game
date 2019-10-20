module Data.Board.Types exposing
    ( Block(..)
    , Board
    , BoardDimensions
    , Coord
    , Move
    , X
    , Y
    )

import Css.Color exposing (Color)
import Data.Board.Tile exposing (TileState)
import Dict exposing (Dict)



-- Core Board Type


type alias BoardDimensions =
    { x : Int
    , y : Int
    }


type alias Board =
    Dict Coord Block


type alias Move =
    ( Coord, Block )


type alias Coord =
    ( Y, X )


type alias Y =
    Int


type alias X =
    Int


type Block
    = Wall Color
    | Space TileState
