module Data.Board.Move exposing
    ( Move
    , areNeighbours
    , block
    , coord
    , empty
    , move
    , sameTileType
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


areNeighbours : Move -> Move -> Bool
areNeighbours move2 move1 =
    let
        checkCoords f =
            f (coord move1) (coord move2)
    in
    [ Coord.isLeft
    , Coord.isRight
    , Coord.isAbove
    , Coord.isBelow
    ]
        |> List.map checkCoords
        |> List.any identity
