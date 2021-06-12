module Game.Board.Coord exposing
    ( Coord
    , X
    , Y
    , fromXY
    , isAbove
    , isBelow
    , isLeft
    , isRight
    , productXY
    , surrounding
    , translateX
    , translateY
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


productXY : List X -> List Y -> List Coord
productXY xs =
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
            productXY xs ys
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



-- Update


translateX : Int -> Coord -> Coord
translateX n coord =
    fromXY (x coord + n) (y coord)


translateY : Int -> Coord -> Coord
translateY n coord =
    fromXY (x coord) (y coord + n)
