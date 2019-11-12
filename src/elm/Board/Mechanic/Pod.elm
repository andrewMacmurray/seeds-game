module Board.Mechanic.Pod exposing
    ( generateNewSeeds
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
import Seed exposing (Seed(..))



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
    in
    twoSeedPods || isFirstSeedMove || isNextSeedMove || isNextSeedPodMove


isSeed : Move -> Bool
isSeed =
    Move.block >> Block.isSeed



-- Generate


generateNewSeeds : (List Tile -> msg) -> Maybe Seed.Seed -> Board -> List Tile.Setting -> Cmd msg
generateNewSeeds msg seedType board settings =
    case seedType of
        Just seed ->
            Generate.constantSeed msg board seed

        _ ->
            Generate.randomSeeds msg board settings



-- Grow


shouldGrow : Board -> Bool
shouldGrow board =
    Board.activeMoveType board == Just SeedPod


growPods : Board -> Board
growPods =
    Board.updateBlocks Block.setDraggingToGrowing >> releaseDraggingSeeds


growSeeds : List Tile -> Board -> Board
growSeeds seeds board =
    board
        |> addGrowingSeeds seeds
        |> growLeavingBurstsToSeeds (activeSeedType board)
        |> resetReleasingSeeds


growLeavingBurstsToSeeds : Seed -> Board -> Board
growLeavingBurstsToSeeds seed =
    Board.updateBlocks (Block.growLeavingBurstToSeed seed)


releaseDraggingSeeds : Board -> Board
releaseDraggingSeeds =
    Board.updateBlocks Block.releaseDraggingSeeds


activeSeedType : Board -> Seed
activeSeedType =
    Board.activeSeedType >> Maybe.withDefault Sunflower


resetReleasingSeeds : Board -> Board
resetReleasingSeeds =
    Board.updateBlocks Block.setReleasingToStatic


addGrowingSeeds : List Tile -> Board -> Board
addGrowingSeeds seeds board_ =
    let
        seedsToAdd =
            board_
                |> filterGrowing
                |> Board.moves
                |> List.map2 setGrowingSeed seeds
    in
    Board.placeMoves board_ seedsToAdd


setGrowingSeed : Tile -> Move -> Move
setGrowingSeed seed =
    Move.updateBlock (Space << Growing seed << Block.growingOrder)


filterGrowing : Board -> Board
filterGrowing =
    Board.filterBlocks Block.isGrowing



-- Reset


reset : Board -> Board
reset =
    Board.updateBlocks Block.setGrowingToStatic
