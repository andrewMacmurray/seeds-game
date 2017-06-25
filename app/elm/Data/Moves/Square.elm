module Data.Moves.Square exposing (..)

import Data.Directions exposing (validDirection)
import Data.Moves.Type exposing (sameTileType, emptyMove)
import List.Extra
import Model exposing (..)


isSquare : List Move -> Bool
isSquare moves =
    if shouldCheckSquare moves then
        let
            first =
                List.head moves

            last =
                List.Extra.last moves
        in
            Maybe.map2 sameCoords first last
                |> Maybe.withDefault False
    else
        False


shouldCheckSquare : List Move -> Bool
shouldCheckSquare moves =
    let
        first =
            List.head moves |> Maybe.withDefault emptyMove

        second =
            List.Extra.getAt 1 moves |> Maybe.withDefault emptyMove
    in
        allTrue
            [ moveLongEnough moves
            , validDirection first second
            , sameTileType first second
            ]


sameCoords : Move -> Move -> Bool
sameCoords ( c1, _ ) ( c2, _ ) =
    c1 == c2


allTrue : List Bool -> Bool
allTrue =
    List.foldr (&&) True


moveLongEnough : List Move -> Bool
moveLongEnough moves =
    (List.length moves) > 4
