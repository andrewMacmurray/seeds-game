module Data.Board.Coord exposing
    ( Coord
    , X
    , Y
    , fromXY
    , isAbove
    , isBelow
    , isLeft
    , isRight
    , rangeXY
    , square
    , surrounding
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


surrounding : { size | x : Int, y : Int } -> Int -> Coord -> List Coord
surrounding size radius center =
    let
        centerX =
            x center

        centerY =
            y center

        xs =
            List.range (centerX - radius) (centerX + radius)

        ys =
            List.range (centerY - radius) (centerY + radius)

        combined =
            rangeXY xs ys
    in
    combined
        |> List.filter (\c -> c /= center)
        |> List.filter (\c -> x c < size.x && y c < size.y)


isLeft : Coord -> Coord -> Bool
isLeft c1 c2 =
    x c2 == x c1 - 1 && y c2 == y c1


isRight : Coord -> Coord -> Bool
isRight c1 c2 =
    x c2 == x c1 + 1 && y c2 == y c1


isAbove : Coord -> Coord -> Bool
isAbove c1 c2 =
    x c2 == x c1 && y c2 == y c1 - 1


isBelow : Coord -> Coord -> Bool
isBelow c1 c2 =
    x c2 == x c1 && y c2 == y c1 + 1
