module Data.Directions exposing (validDirection)

import Model exposing (..)


isLeft : Coord -> Coord -> Bool
isLeft ( x1, y1 ) ( x2, y2 ) =
    x2 == x1 - 1 && y2 == y1


isRight : Coord -> Coord -> Bool
isRight ( x1, y1 ) ( x2, y2 ) =
    x2 == x1 + 1 && y2 == y1


isAbove : Coord -> Coord -> Bool
isAbove ( x1, y1 ) ( x2, y2 ) =
    x2 == x1 && y2 == y1 - 1


isBelow : Coord -> Coord -> Bool
isBelow ( x1, y1 ) ( x2, y2 ) =
    x2 == x1 && y2 == y1 + 1


isLeftAndAbove : Coord -> Coord -> Bool
isLeftAndAbove ( x1, y1 ) ( x2, y2 ) =
    x2 == x1 - 1 && y2 == y1 - 1


isRightAndAbove : Coord -> Coord -> Bool
isRightAndAbove ( x1, y1 ) ( x2, y2 ) =
    x2 == x1 + 1 && y2 == y1 - 1


isLeftAndBelow : Coord -> Coord -> Bool
isLeftAndBelow ( x1, y1 ) ( x2, y2 ) =
    x2 == x1 - 1 && y2 == y1 + 1


isRightAndBelow : Coord -> Coord -> Bool
isRightAndBelow ( x1, y1 ) ( x2, y2 ) =
    x2 == x1 + 1 && y2 == y1 + 1


anyTrue : List Bool -> Bool
anyTrue =
    List.foldl (||) False


directionsToCheck : List (Coord -> Coord -> Bool)
directionsToCheck =
    [ isLeft
    , isRight
    , isAbove
    , isBelow
    , isLeftAndAbove
    , isRightAndAbove
    , isLeftAndBelow
    , isRightAndBelow
    ]


check : a -> a -> (a -> a -> Bool) -> Bool
check a b fn =
    fn a b


validDirection : Move -> Move -> Bool
validDirection ( c2, _ ) ( c1, _ ) =
    List.map (check c2 c1) directionsToCheck
        |> anyTrue
