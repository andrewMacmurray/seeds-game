module Data.Board exposing
    ( Board
    , Size
    , blocks
    , coords
    , currentMoveType
    , currentMoves
    , filter
    , filterBlocks
    , findBlockAt
    , fromMoves
    , fromTiles
    , inCurrentMoves
    , isEmpty
    , lastMove
    , moves
    , place
    , placeAt
    , placeMoves
    , secondLastMove
    , size
    , update
    , updateAt
    , updateBlocks
    )

import Data.Board.Block as Block exposing (Block)
import Data.Board.Coord as Coord exposing (Coord)
import Data.Board.Move as Move exposing (Move)
import Data.Board.Tile as Tile
import Dict exposing (Dict)
import Helpers.Dict



-- Board


type Board
    = Board (Dict Coord Block)


type alias Size =
    { x : Int
    , y : Int
    }



-- Update


updateAt : Coord -> (Block -> Block) -> Board -> Board
updateAt coord f =
    aroundBoard (Dict.update coord <| Maybe.map f)


placeMoves : Board -> List Move -> Board
placeMoves =
    List.foldl place


placeAt : Coord -> Block -> Board -> Board
placeAt coord block =
    Move.move coord block |> place


place : Move -> Board -> Board
place move =
    aroundBoard (Dict.update (Move.coord move) <| Maybe.map (always <| Move.block move))


updateBlocks : (Block -> Block) -> Board -> Board
updateBlocks f =
    update <| always f


update : (Coord -> Block -> Block) -> Board -> Board
update f =
    aroundBoard (Dict.map f)


filterBlocks : (Block -> Bool) -> Board -> Board
filterBlocks f =
    filter <| always f


filter : (Coord -> Block -> Bool) -> Board -> Board
filter f =
    aroundBoard (Dict.filter f)



-- Query


size : Board -> Int
size =
    unwrap >> Dict.size


isEmpty : Board -> Bool
isEmpty =
    unwrap >> Dict.isEmpty


coords : Board -> List Coord
coords =
    unwrap >> Dict.keys


blocks : Board -> List Block
blocks =
    unwrap >> Dict.values


moves : Board -> List Move
moves =
    unwrap >> Dict.toList >> List.map toMove


findBlockAt : Coord -> Board -> Maybe Block
findBlockAt c =
    unwrap >> Dict.get c


matchBlock : (Block -> Bool) -> Board -> Maybe Move
matchBlock f =
    unwrap >> Helpers.Dict.findValue f >> Maybe.map toMove



-- Moves


currentMoves : Board -> List Move
currentMoves =
    filterBlocks Block.isDragging
        >> moves
        >> List.sortBy (Move.block >> Block.moveOrder)


currentMoveType : Board -> Maybe Tile.Type
currentMoveType =
    filterBursts
        >> matchBlock Block.isDragging
        >> Maybe.andThen Move.tileType


filterBursts : Board -> Board
filterBursts =
    filterBlocks (not << Block.isBurst)


inCurrentMoves : Move -> Board -> Bool
inCurrentMoves move =
    currentMoves >> List.member move


lastMove : Board -> Move
lastMove =
    matchBlock Block.isCurrentMove >> Maybe.withDefault Move.empty


secondLastMove : Board -> Maybe Move
secondLastMove =
    currentMoves
        >> List.reverse
        >> List.drop 1
        >> List.head



-- Create


fromTiles : Size -> List Tile.Type -> Board
fromTiles boardDimensions tiles =
    tiles
        |> List.map Block.static
        |> List.map2 Move.move (makeCoords boardDimensions)
        |> fromMoves


makeCoords : Size -> List Coord
makeCoords { x, y } =
    Coord.rangeXY (range x) (range y)


range : Int -> List Int
range n =
    List.range 0 (n - 1)


fromMoves : List Move -> Board
fromMoves =
    List.map fromMove >> Dict.fromList >> wrap



-- Helpers


toMove : ( Coord, Block ) -> Move
toMove ( coord, block ) =
    Move.move coord block


fromMove : Move -> ( Coord, Block )
fromMove move =
    ( Move.coord move, Move.block move )


aroundBoard : (Dict Coord Block -> Dict Coord Block) -> Board -> Board
aroundBoard f =
    unwrap >> f >> wrap


wrap : Dict Coord Block -> Board
wrap =
    Board


unwrap : Board -> Dict Coord Block
unwrap (Board board) =
    board
