module Game.Board.Mechanic.Pod exposing
    ( generateNewSeeds
    , growPods
    , growSeeds
    , isValidNextMove
    , reset
    , shouldGrow
    )

import Game.Board as Board exposing (Board)
import Game.Board.Block as Block exposing (Block(..))
import Game.Board.Generate as Generate
import Game.Board.Move as Move exposing (Move)
import Game.Board.Move.Check as Check
import Game.Board.Tile as Tile exposing (State(..), Tile(..))
import Game.Level.Tile as Tile
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


growSeeds : List Tile -> List Tile.Setting -> Board -> Board
growSeeds seeds settings board =
    board
        |> addGrowingSeeds seeds
        |> growLeavingBurstsToSeeds (growingSeedType settings board)
        |> resetReleasingSeeds


growLeavingBurstsToSeeds : Seed -> Board -> Board
growLeavingBurstsToSeeds seed =
    Board.updateBlocks (Block.growLeavingBurstToSeed seed)


releaseDraggingSeeds : Board -> Board
releaseDraggingSeeds =
    Board.updateBlocks Block.releaseDraggingSeeds


growingSeedType : List Tile.Setting -> Board -> Seed
growingSeedType settings =
    Board.growingSeedType
        >> fallbackToHighestProbabilitySeed settings
        >> Maybe.withDefault Sunflower


fallbackToHighestProbabilitySeed : List Tile.Setting -> Maybe Seed -> Maybe Seed
fallbackToHighestProbabilitySeed settings seed =
    case seed of
        Nothing ->
            settings
                |> Tile.seedSettings
                |> Tile.sortByProbability
                |> List.head
                |> Maybe.map .tileType
                |> Maybe.andThen Tile.seedType

        _ ->
            seed


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
