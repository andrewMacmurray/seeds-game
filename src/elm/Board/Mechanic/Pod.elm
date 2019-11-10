module Board.Mechanic.Pod exposing
    ( generateSeedType
    , growPods
    , growSeeds
    , isValidNextMove
    , reset
    , shouldGrow
    )

import Board exposing (Board)
import Board.Block as Block exposing (Block(..))
import Board.Generate as Generate
import Board.Move as Move exposing (Move)
import Board.Move.Check as Check
import Board.Tile exposing (State(..), Tile(..))
import Level.Setting.Tile as Tile
import Seed exposing (Seed)



-- Valid Next Move


isValidNextMove : Move -> Board -> Bool
isValidNextMove move board =
    let
        activeSeed =
            Board.activeSeed board

        isActiveSeedPodMove =
            Board.activeMoveType board == Just SeedPod

        moveType =
            Move.tile move

        isSeedPodMove =
            moveType == Just SeedPod

        twoSeedPods =
            isSeedPodMove && sameTileType

        isFirstSeedMove =
            isSeed move && activeSeed == Nothing && isActiveSeedPodMove

        isNextSeedMove =
            moveType == activeSeed && isActiveSeedPodMove

        sameTileType =
            Check.sameActiveTileType move board

        isNextSeedPodMove =
            isActiveSeedPodMove && isSeedPodMove

        isMatchingMove =
            twoSeedPods || isFirstSeedMove || isNextSeedMove || isNextSeedPodMove

        isNewNeighbour =
            Check.isNewNeighbour move board
    in
    isMatchingMove && isNewNeighbour


isSeed : Move -> Bool
isSeed =
    Move.block >> Block.isSeed



-- Generate


generateSeedType : (Seed -> msg) -> Board -> List Tile.Setting -> Cmd msg
generateSeedType msg board settings =
    case Board.activeSeed board of
        Just (Seed seed) ->
            Generate.constantSeed msg seed

        _ ->
            Generate.randomSeed msg settings



-- Grow


shouldGrow : Board -> Bool
shouldGrow board =
    Board.activeMoveType board == Just SeedPod


growPods : Board -> Board
growPods =
    Board.updateBlocks Block.setDraggingToGrowing


growSeeds : Seed -> Board -> Board
growSeeds seed =
    addGrowingSeeds seed >> growLeavingBurstsToSeeds seed


growLeavingBurstsToSeeds : Seed -> Board -> Board
growLeavingBurstsToSeeds seed =
    Board.updateBlocks (Block.growLeavingBurstToSeed seed)


addGrowingSeeds : Seed -> Board -> Board
addGrowingSeeds seed board_ =
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
