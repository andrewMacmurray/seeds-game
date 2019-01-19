module Data.Board.Coord exposing
    ( fromRangesXY
    , fromXY
    , x
    , y
    )

import Data.Board.Types exposing (Coord)


fromRangesXY : List Int -> List Int -> List Coord
fromRangesXY xs =
    List.map (\y_ -> List.map (\x_ -> fromXY x_ y_) xs) >> List.concat


fromXY : Int -> Int -> Coord
fromXY x_ y_ =
    ( y_, x_ )


x : Coord -> Int
x =
    Tuple.second


y : Coord -> Int
y =
    Tuple.first
