module Data.Board.Generate exposing
    ( addBlock
    , generateEnteringTiles
    , generateInitialTiles
    , generateRandomSeedType
    , insertNewEnteringTiles
    , insertNewSeeds
    , mono
    )

import Data.Board as Board
import Data.Board.Block as Block
import Data.Board.Coord as Coord
import Data.Board.Move as Move
import Data.Board.Tile as Tile
import Data.Board.Types exposing (..)
import Data.Level.Setting exposing (Probability(..), TileSetting)
import Random exposing (Generator)



-- Growing Tiles


insertNewSeeds : SeedType -> Board -> Board
insertNewSeeds seedType board =
    let
        seedsToAdd =
            board
                |> filterGrowing
                |> Board.moves
                |> List.map (setGrowingSeed seedType)
    in
    Board.placeMoves board seedsToAdd


setGrowingSeed : SeedType -> Move -> Move
setGrowingSeed seedType ( coord, block ) =
    ( coord
    , Space <| Growing (Seed seedType) <| Block.growingOrder block
    )


generateRandomSeedType : (SeedType -> msg) -> List TileSetting -> Cmd msg
generateRandomSeedType msg =
    seedTypeGenerator >> Random.generate msg


numberOfGrowingPods : Board -> Int
numberOfGrowingPods =
    filterGrowing >> Board.size


getGrowingCoords : Board -> List Coord
getGrowingCoords =
    filterGrowing >> Board.coords


filterGrowing : Board -> Board
filterGrowing =
    Board.filterBlocks Block.isGrowing



-- Entering Tiles


insertNewEnteringTiles : List TileType -> Board -> Board
insertNewEnteringTiles newTiles board =
    let
        tilesToAdd =
            board
                |> getEmptyCoords
                |> List.map2 (\tile coord -> ( coord, Space <| Entering tile )) newTiles
    in
    Board.placeMoves board tilesToAdd


generateEnteringTiles : (List TileType -> msg) -> Board -> List TileSetting -> Cmd msg
generateEnteringTiles msg board tileSettings =
    tileGenerator tileSettings
        |> Random.list (numberOfEmpties board)
        |> Random.generate msg


numberOfEmpties : Board -> Int
numberOfEmpties =
    filterEmpties >> Board.size


getEmptyCoords : Board -> List Coord
getEmptyCoords =
    filterEmpties >> Board.coords


filterEmpties : Board -> Board
filterEmpties =
    Board.filterBlocks Block.isEmpty


addBlock : Coord -> TileType -> Board -> Board
addBlock coord tileType =
    Board.placeAt coord <| Block.static tileType


mono : TileType -> BoardDimensions -> Board
mono tileType ({ x, y } as scale) =
    Board.fromTiles scale <| List.repeat (x * y) tileType



-- Generate Board


generateInitialTiles : (List TileType -> msg) -> List TileSetting -> BoardDimensions -> Cmd msg
generateInitialTiles msg tileSettings { x, y } =
    Random.list (x * y) (tileGenerator tileSettings)
        |> Random.generate msg


seedTypeGenerator : List TileSetting -> Generator SeedType
seedTypeGenerator =
    filterSeedSettings
        >> tileGenerator
        >> Random.map (Tile.getSeedType >> Maybe.withDefault Sunflower)


filterSeedSettings : List TileSetting -> List TileSetting
filterSeedSettings =
    List.filter (.tileType >> Tile.isSeed)


tileGenerator : List TileSetting -> Generator TileType
tileGenerator tileSettings =
    Random.int 0 (totalProbability tileSettings) |> Random.map (tileProbability tileSettings)



-- Probabilities


totalProbability : List TileSetting -> Int
totalProbability tileSettings =
    tileSettings
        |> List.map .probability
        |> List.map (\(Probability p) -> p)
        |> List.sum


tileProbability : List TileSetting -> Int -> TileType
tileProbability tileSettings n =
    tileSettings
        |> List.foldl (evalProbability n) ( Nothing, 0 )
        |> Tuple.first
        |> Maybe.withDefault SeedPod


evalProbability : Int -> TileSetting -> ( Maybe TileType, Int ) -> ( Maybe TileType, Int )
evalProbability n { tileType, probability } ( val, accProb ) =
    let
        (Probability p) =
            probability
    in
    case val of
        Nothing ->
            if n <= p + accProb then
                ( Just tileType, p )

            else
                ( Nothing, p + accProb )

        Just tileType_ ->
            ( Just tileType_, p )
