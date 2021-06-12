module Game.Board exposing
    ( Board
    , Size
    , activeMoveType
    , activeMoves
    , activeSeed
    , activeSeedType
    , blocks
    , coords
    , empty
    , filter
    , filterBlocks
    , findBlockAt
    , fromMoves
    , fromTiles
    , growingSeedType
    , isActiveMove
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

import Dict exposing (Dict)
import Game.Board.Block as Block exposing (Block)
import Game.Board.Coord as Coord exposing (Coord)
import Game.Board.Move as Move exposing (Move)
import Game.Board.Tile as Tile exposing (Tile(..))
import Seed exposing (Seed)
import Utils.Dict



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
    unwrap >> Utils.Dict.findValue f >> Maybe.map toMove



-- Moves


activeMoves : Board -> List Move
activeMoves =
    filterBlocks Block.isDragging
        >> moves
        >> List.sortBy (Move.block >> Block.moveOrder)


activeMoveType : Board -> Maybe Tile
activeMoveType board =
    if isSeedPodMove board then
        Just SeedPod

    else
        draggingMoveType board


activeSeedType : Board -> Maybe Seed
activeSeedType =
    activeSeed >> Maybe.andThen Tile.seedType


growingSeedType : Board -> Maybe Seed
growingSeedType =
    releasingMoves
        >> firstSeedTileFromMoves
        >> Maybe.andThen Tile.seedType


activeSeed : Board -> Maybe Tile
activeSeed =
    activeMoves >> firstSeedTileFromMoves


firstSeedTileFromMoves : List Move -> Maybe Tile
firstSeedTileFromMoves =
    List.map Move.block
        >> List.filter Block.isSeed
        >> List.head
        >> Maybe.andThen Block.tile


releasingMoves : Board -> List Move
releasingMoves =
    filterBlocks Block.isReleasing >> moves


draggingMoveType : Board -> Maybe Tile
draggingMoveType =
    filterBursts
        >> matchBlock Block.isDragging
        >> Maybe.andThen Move.tile


isSeedPodMove : Board -> Bool
isSeedPodMove =
    activeMoves
        >> List.map Move.tile
        >> List.member (Just SeedPod)


filterBursts : Board -> Board
filterBursts =
    filterBlocks (not << Block.isBurst)


isActiveMove : Move -> Board -> Bool
isActiveMove move =
    activeMoves >> List.member move


lastMove : Board -> Move
lastMove =
    matchBlock Block.isCurrentMove >> Maybe.withDefault Move.empty


secondLastMove : Board -> Maybe Move
secondLastMove =
    activeMoves
        >> List.reverse
        >> List.drop 1
        >> List.head



-- Create


fromTiles : Size -> List Tile -> Board
fromTiles boardDimensions tiles =
    tiles
        |> List.map Block.static
        |> List.map2 Move.move (makeCoords boardDimensions)
        |> fromMoves


makeCoords : Size -> List Coord
makeCoords { x, y } =
    Coord.productXY (range x) (range y)


range : Int -> List Int
range n =
    List.range 0 (n - 1)


fromMoves : List Move -> Board
fromMoves =
    List.map fromMove >> Dict.fromList >> wrap


empty : Board
empty =
    fromMoves []



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
