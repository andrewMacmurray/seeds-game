module Data.Board.Coord exposing
    ( Coord
    , X
    , Y
    , fromXY
    , rangeXY
    , square
    , x
    , y
    )

-- Coord


type alias Coord =
    ( Y, X )


type alias Y =
    Int


type alias X =
    Int



-- Construct


square : { a | x : Int, y : Int, size : Int } -> List Coord
square options =
    rangeXY
        (List.range options.x (options.x + options.size - 1))
        (List.range options.y (options.y + options.size - 1))


rangeXY : List X -> List Y -> List Coord
rangeXY xs =
    List.map (\y_ -> List.map (\x_ -> fromXY x_ y_) xs) >> List.concat


fromXY : X -> Y -> Coord
fromXY x_ y_ =
    ( y_, x_ )



-- Query


x : Coord -> X
x =
    Tuple.second


y : Coord -> Y
y =
    Tuple.first
