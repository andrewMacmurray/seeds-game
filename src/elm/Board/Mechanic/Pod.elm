module Board.Mechanic.Pod exposing
    ( growPods
    , growSeeds
    , isValidNextMove
    , reset
    , shouldGrow
    )

import Board exposing (Board)
import Board.Block as Block exposing (Block(..))
import Board.Move as Move exposing (Move)
import Board.Move.Check as Check
import Board.Tile exposing (State(..), Tile(..))
import Seed exposing (Seed)



-- Valid Next Move


isValidNextMove : Move -> Board -> Bool
isValidNextMove move board =
    let
        isPod =
            Move.tile move == Just SeedPod

        sameTileType =
            Check.sameActiveTileType move board

        isNewNeighbour =
            Check.isNewNeighbour move board
    in
    isPod && sameTileType && isNewNeighbour



-- Grow


shouldGrow : Board -> Bool
shouldGrow board =
    Board.activeMoveType board == Just SeedPod


growPods : Board -> Board
growPods =
    Board.updateBlocks Block.setDraggingToGrowing


growSeeds : Seed -> Board -> Board
growSeeds seed =
    insertGrowingSeeds seed >> growLeavingBurstsToSeeds seed


growLeavingBurstsToSeeds : Seed -> Board -> Board
growLeavingBurstsToSeeds seed =
    Board.updateBlocks (Block.growLeavingBurstToSeed seed)


insertGrowingSeeds : Seed -> Board -> Board
insertGrowingSeeds seed board_ =
    let
        seedsToAdd =
            board_
                |> filterGrowing
                |> Board.moves
                |> List.map (setGrowingSeed seed)
    in
    Board.placeMoves board_ seedsToAdd


setGrowingSeed : Seed -> Move -> Move
setGrowingSeed seed =
    Move.updateBlock (Space << Growing (Seed seed) << Block.growingOrder)


filterGrowing : Board -> Board
filterGrowing =
    Board.filterBlocks Block.isGrowing



-- Reset


reset : Board -> Board
reset =
    Board.updateBlocks Block.setGrowingToStatic
