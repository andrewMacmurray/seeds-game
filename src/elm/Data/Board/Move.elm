module Data.Board.Move exposing
    ( Move
    , areNeighbours
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
    , tileState
    , tileType
    , x
    , y
    )

import Data.Board.Block as Block exposing (Block)
import Data.Board.Coord as Coord exposing (Coord)
import Data.Board.Tile as Tile



-- Move


type alias Move =
    ( Coord, Block )



-- Construct


move : Coord -> Block -> Move
move c b =
    ( c, b )


empty : Move
empty =
    ( Coord.fromXY 0 0
    , Block.empty
    )



-- Query


coord : Move -> Coord
coord =
    Tuple.first


block : Move -> Block
block =
    Tuple.second


tileState : Move -> Tile.State
tileState =
    block >> Block.getTileState


x : Move -> Int
x =
    coord >> Coord.x


y : Move -> Int
y =
    coord >> Coord.y


tileType : Move -> Maybe Tile.Type
tileType =
    block >> Block.tileType


sameTileType : Move -> Move -> Bool
sameTileType m1 m2 =
    tileType m1 == tileType m2


surroundingCoordinates : { size | x : Int, y : Int } -> Int -> Coord -> List Coord
surroundingCoordinates size radius center =
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
        |> List.filter (\c -> Coord.x c < size.x && Coord.y c < size.y)


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
