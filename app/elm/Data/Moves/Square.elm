module Data.Moves.Square exposing (..)

import Data.Directions exposing (validDirection)
import Data.Moves.Type exposing (sameTileType, emptyMove)
import List.Extra
import Model exposing (..)


isValidSquare : List Move -> Bool
isValidSquare moves =
    if shouldCheckSquare moves then
        moves
            |> List.head
            |> Maybe.andThen (checkSquareInCurrentMove moves)
            |> Maybe.withDefault False
    else
        False


checkSquareInCurrentMove : List Move -> Move -> Maybe Bool
checkSquareInCurrentMove moves current =
    moves
        |> List.drop 1
        |> List.Extra.elemIndex current
        |> Maybe.map (\x -> x > 2)


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


allTrue : List Bool -> Bool
allTrue =
    List.foldr (&&) True


moveLongEnough : List Move -> Bool
moveLongEnough moves =
    (List.length moves) > 4
