module Data.Board.Move exposing
    ( areNeighbours
    , block
    , coord
    , currentMoveTileType
    , currentMoves
    , inCurrentMoves
    , isAbove
    , isBelow
    , isLeft
    , isRight
    , last
    , sameTileType
    , secondLast
    , surroundingCoordinates
    , tileType
    )

import Data.Board.Block as Block
import Data.Board.Types exposing (..)
import Dict
import Helpers.Dict exposing (filterValues, find, findValue)


currentMoves : Board -> List Move
currentMoves board =
    board
        |> filterValues Block.isDragging
        |> Dict.toList
        |> List.sortBy (Tuple.second >> Block.moveOrder)


currentMoveTileType : Board -> Maybe TileType
currentMoveTileType board =
    board
        |> filterValues (not << Block.isBurst)
        |> findValue Block.isDragging
        |> Maybe.andThen tileType


surroundingCoordinates : BoardDimensions -> Int -> Coord -> List Coord
surroundingCoordinates dimensions radius (( centerY, centerX ) as center) =
    let
        xs =
            List.range (centerX - radius) (centerX + radius)

        ys =
            List.range (centerY - radius) (centerY + radius)

        combined =
            List.map (\x -> List.map (\y -> ( y, x )) ys) xs
    in
    combined
        |> List.concat
        |> List.filter (\c -> c /= center)
        |> List.filter (\( x_, y_ ) -> x_ < dimensions.x && y_ < dimensions.y)


sameTileType : Move -> Move -> Bool
sameTileType m1 m2 =
    tileType m1 == tileType m2


tileType : Move -> Maybe TileType
tileType =
    block >> Block.getTileType


inCurrentMoves : Move -> Board -> Bool
inCurrentMoves move board =
    board
        |> currentMoves
        |> List.member move


last : Board -> Move
last board =
    board
        |> findValue Block.isCurrentMove
        |> Maybe.withDefault empty


secondLast : Board -> Maybe Move
secondLast board =
    board
        |> currentMoves
        |> List.reverse
        |> List.drop 1
        |> List.head


coord : Move -> Coord
coord =
    Tuple.first


block : Move -> Block
block =
    Tuple.second


coordsList : Board -> List Coord
coordsList board =
    board
        |> filterValues Block.isDragging
        |> Dict.keys


empty : Move
empty =
    ( ( 0, 0 ), Space Empty )


areNeighbours : Move -> Move -> Bool
areNeighbours ( c2, _ ) ( c1, _ ) =
    let
        check a b f =
            f a b
    in
    List.map (check c2 c1)
        [ isLeft
        , isRight
        , isAbove
        , isBelow
        ]
        |> List.any identity


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
