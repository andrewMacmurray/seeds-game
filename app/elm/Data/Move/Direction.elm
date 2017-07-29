module Data.Move.Direction exposing (..)

import Model exposing (..)
import Helpers.List exposing (anyTrue)


isLeft : Coord -> Coord -> Bool
isLeft ( y1, x1 ) ( y2, x2 ) =
    x2 == x1 - 1 && y2 == y1


isRight : Coord -> Coord -> Bool
isRight ( y1, x1 ) ( y2, x2 ) =
    x2 == x1 + 1 && y2 == y1


isAbove : Coord -> Coord -> Bool
isAbove ( y1, x1 ) ( y2, x2 ) =
    x2 == x1 && y2 == y1 - 1


isBelow : Coord -> Coord -> Bool
isBelow ( y1, x1 ) ( y2, x2 ) =
    x2 == x1 && y2 == y1 + 1


directionsToCheck : List (Coord -> Coord -> Bool)
directionsToCheck =
    [ isLeft
    , isRight
    , isAbove
    , isBelow
    ]


check : a -> a -> (a -> a -> Bool) -> Bool
check a b fn =
    fn a b


validDirection : Move -> Move -> Bool
validDirection ( c2, _ ) ( c1, _ ) =
    List.map (check c2 c1) directionsToCheck
        |> anyTrue
