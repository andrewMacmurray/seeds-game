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
    , move
    , sameTileType
    , secondLast
    , surroundingCoordinates
    , tileType
    , x
    , y
    )

import Data.Board.Block as Block
import Data.Board.Coord as Coord
import Data.Board.Types exposing (..)
import Dict
import Helpers.Dict exposing (filterValues, find, findValue)


currentMoves : Board -> List Move
currentMoves =
    filterValues Block.isDragging
        >> Dict.toList
        >> List.sortBy (Tuple.second >> Block.moveOrder)


currentMoveTileType : Board -> Maybe TileType
currentMoveTileType =
    filterValues (not << Block.isBurst)
        >> findValue Block.isDragging
        >> Maybe.andThen tileType


surroundingCoordinates : BoardDimensions -> Int -> Coord -> List Coord
surroundingCoordinates dimensions radius center =
    let
        centerX =
            Coord.x center

        centerY =
            Coord.y center

        xs =
            List.range (centerX - radius) (centerX + radius)

        ys =
            List.range (centerY - radius) (centerY + radius)

        combined =
            Coord.fromRangesXY xs ys
    in
    combined
        |> List.filter (\c -> c /= center)
        |> List.filter (\c -> Coord.x c < dimensions.x && Coord.y c < dimensions.y)


sameTileType : Move -> Move -> Bool
sameTileType m1 m2 =
    tileType m1 == tileType m2


tileType : Move -> Maybe TileType
tileType =
    block >> Block.getTileType


inCurrentMoves : Move -> Board -> Bool
inCurrentMoves move_ =
    currentMoves >> List.member move_


last : Board -> Move
last =
    findValue Block.isCurrentMove >> Maybe.withDefault empty


secondLast : Board -> Maybe Move
secondLast =
    currentMoves
        >> List.reverse
        >> List.drop 1
        >> List.head


move : Coord -> Block -> Move
move c b =
    ( c, b )


x : Move -> Int
x =
    coord >> Coord.x


y : Move -> Int
y =
    coord >> Coord.y


coord : Move -> Coord
coord =
    Tuple.first


block : Move -> Block
block =
    Tuple.second


empty : Move
empty =
    ( Coord.fromXY 0 0
    , Space Empty
    )


areNeighbours : Move -> Move -> Bool
areNeighbours m1 m2 =
    let
        checkCoords f =
            f (coord m2) (coord m1)
    in
    List.map checkCoords
        [ isLeft
        , isRight
        , isAbove
        , isBelow
        ]
        |> List.any identity


isLeft : Coord -> Coord -> Bool
isLeft c1 c2 =
    Coord.x c2 == Coord.x c1 - 1 && Coord.y c2 == Coord.y c1


isRight : Coord -> Coord -> Bool
isRight c1 c2 =
    Coord.x c2 == Coord.x c1 + 1 && Coord.y c2 == Coord.y c1


isAbove : Coord -> Coord -> Bool
isAbove c1 c2 =
    Coord.x c2 == Coord.x c1 && Coord.y c2 == Coord.y c1 - 1


isBelow : Coord -> Coord -> Bool
isBelow c1 c2 =
    Coord.x c2 == Coord.x c1 && Coord.y c2 == Coord.y c1 + 1
