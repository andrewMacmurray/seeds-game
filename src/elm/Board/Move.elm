module Board.Move exposing
    ( Move
    , areNeighbours
    , block
    , coord
    , empty
    , move
    , sameTileType
    , tile
    , tileState
    , updateBlock
    , x
    , y
    )

import Board.Block as Block exposing (Block)
import Board.Coord as Coord exposing (Coord)
import Board.Tile as Tile exposing (Tile)



-- Move


type Move
    = Move Coord Block



-- Construct


move : Coord -> Block -> Move
move =
    Move


empty : Move
empty =
    Move (Coord.fromXY 0 0) Block.empty



-- Query


coord : Move -> Coord
coord (Move c _) =
    c


block : Move -> Block
block (Move _ b) =
    b


tileState : Move -> Tile.State
tileState =
    block >> Block.tileState


x : Move -> Int
x =
    coord >> Coord.x


y : Move -> Int
y =
    coord >> Coord.y


tile : Move -> Maybe Tile
tile =
    block >> Block.tile



-- Checks


sameTileType : Move -> Move -> Bool
sameTileType m1 m2 =
    tile m1 == tile m2


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



-- Update


updateBlock : (Block -> Block) -> Move -> Move
updateBlock f (Move c b) =
    Move c (f b)
