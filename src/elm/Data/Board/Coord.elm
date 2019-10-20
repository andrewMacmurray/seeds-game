module Data.Board.Coord exposing
    ( fromXY
    , rangeXY
    , square
    , x
    , y
    )

import Data.Board.Types exposing (Coord)


square : { a | x : Int, y : Int, size : Int } -> List Coord
square options =
    rangeXY
        (List.range options.x (options.x + options.size - 1))
        (List.range options.y (options.y + options.size - 1))


rangeXY : List Int -> List Int -> List Coord
rangeXY xs =
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
