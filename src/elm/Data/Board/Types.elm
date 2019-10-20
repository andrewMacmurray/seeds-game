module Data.Board.Types exposing
    ( Board
    , BoardDimensions
    , Coord
    , Move
    , X
    , Y
    )

import Data.Board.Block exposing (Block)
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
