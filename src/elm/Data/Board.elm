module Data.Board exposing
    ( blocks
    , coords
    , filter
    , filterBlocks
    , findBlockAt
    , fromMoves
    , fromTiles
    , isEmpty
    , map
    , mapBlocks
    , moves
    , place
    , placeAt
    , placeMoves
    , size
    , updateAt
    )

import Data.Board.Block as Block
import Data.Board.Coord as Coord
import Data.Board.Move as Move
import Data.Board.Types exposing (Block, Board, BoardDimensions, Coord, Move, TileType)
import Dict



-- Update


updateAt : Coord -> (Block -> Block) -> Board -> Board
updateAt coord f =
    Dict.update coord <| Maybe.map f


placeMoves : Board -> List Move -> Board
placeMoves =
    List.foldl place


placeAt : Coord -> Block -> Board -> Board
placeAt coord block =
    Move.move coord block |> place


place : Move -> Board -> Board
place move =
    Dict.update (Move.coord move) <| Maybe.map (always <| Move.block move)


mapBlocks : (Block -> Block) -> Board -> Board
mapBlocks f =
    map <| always f


map : (Coord -> Block -> Block) -> Board -> Board
map =
    Dict.map


filterBlocks : (Block -> Bool) -> Board -> Board
filterBlocks f =
    filter <| always f


filter : (Coord -> Block -> Bool) -> Board -> Board
filter =
    Dict.filter



-- Query


size : Board -> Int
size =
    Dict.size


isEmpty : Board -> Bool
isEmpty =
    Dict.isEmpty


coords : Board -> List Coord
coords =
    Dict.keys


blocks : Board -> List Block
blocks =
    Dict.values


moves : Board -> List Move
moves =
    Dict.toList


findBlockAt : Coord -> Board -> Maybe Block
findBlockAt =
    Dict.get



-- Create


fromTiles : BoardDimensions -> List TileType -> Board
fromTiles boardDimensions tiles =
    tiles
        |> List.map Block.static
        |> List.map2 Move.move (makeCoords boardDimensions)
        |> fromMoves


makeCoords : BoardDimensions -> List Coord
makeCoords { x, y } =
    Coord.fromRangesXY (range x) (range y)


range : Int -> List Int
range n =
    List.range 0 (n - 1)


fromMoves : List Move -> Board
fromMoves =
    Dict.fromList
