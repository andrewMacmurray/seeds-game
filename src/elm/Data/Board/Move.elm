module Data.Board.Move exposing
    ( areNeighbours
    , block
    , coord
    , empty
    , isAbove
    , isBelow
    , isLeft
    , isRight
    , move
    , sameTileType
    , surroundingCoordinates
    , tileType
    , x
    , y
    )

import Data.Board.Block as Block
import Data.Board.Coord as Coord
import Data.Board.Types exposing (Block, BoardDimensions, Coord, Move, TileType)


move : Coord -> Block -> Move
move c b =
    ( c, b )


coord : Move -> Coord
coord =
    Tuple.first


block : Move -> Block
block =
    Tuple.second


x : Move -> Int
x =
    coord >> Coord.x


y : Move -> Int
y =
    coord >> Coord.y


tileType : Move -> Maybe TileType
tileType =
    block >> Block.getTileType


sameTileType : Move -> Move -> Bool
sameTileType m1 m2 =
    tileType m1 == tileType m2


empty : Move
empty =
    ( Coord.fromXY 0 0
    , Block.empty
    )


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
            Coord.rangeXY xs ys
    in
    combined
        |> List.filter (\c -> c /= center)
        |> List.filter (\c -> Coord.x c < dimensions.x && Coord.y c < dimensions.y)


areNeighbours : Move -> Move -> Bool
areNeighbours m1 m2 =
    let
        checkCoords f =
            f (coord m2) (coord m1)
    in
    [ isLeft
    , isRight
    , isAbove
    , isBelow
    ]
        |> List.map checkCoords
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
