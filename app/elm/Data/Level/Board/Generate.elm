module Data.Level.Board.Generate exposing (..)

import Data.Level.Board.Probabilities exposing (tileProbability)
import Data.Level.Board.Tile exposing (getSeedType, growingOrder, isGrowing, isSeedTile)
import Dict
import Random exposing (Generator)
import Scenes.Hub.Types exposing (..)
import Scenes.Level.Types as Level exposing (..)


-- Growing Tiles


insertNewSeeds : SeedType -> Board -> Board
insertNewSeeds seedType board =
    let
        seedsToAdd =
            board
                |> filterGrowing
                |> Dict.toList
                |> List.map (setGrowingSeed seedType)
                |> Dict.fromList
    in
        Dict.union seedsToAdd board


setGrowingSeed : SeedType -> ( Coord, Block ) -> ( Coord, Block )
setGrowingSeed seedType ( coord, block ) =
    ( coord, Space <| Growing (Seed seedType) <| growingOrder block )


generateRandomSeedType : List TileSetting -> Cmd Level.Msg
generateRandomSeedType tileSettings =
    tileSettings
        |> seedTypeGenerator
        |> Random.generate InsertGrowingSeeds


numberOfGrowingPods : Board -> Int
numberOfGrowingPods board =
    board
        |> filterGrowing
        |> Dict.size


getGrowingCoords : Board -> List Coord
getGrowingCoords board =
    board
        |> filterGrowing
        |> Dict.keys


filterGrowing : Board -> Board
filterGrowing board =
    board |> Dict.filter (\_ tile -> isGrowing tile)



-- Entering Tiles


insertNewEnteringTiles : List TileType -> Board -> Board
insertNewEnteringTiles newTiles board =
    let
        tilesToAdd =
            board
                |> getEmptyCoords
                |> List.map2 (\tile coord -> ( coord, Space <| Entering tile )) newTiles
                |> Dict.fromList
    in
        Dict.union tilesToAdd board


generateEnteringTiles : List TileSetting -> Board -> Cmd Level.Msg
generateEnteringTiles tileSettings board =
    (tileGenerator tileSettings)
        |> Random.list (numberOfEmpties board)
        |> Random.generate InsertEnteringTiles


numberOfEmpties : Board -> Int
numberOfEmpties board =
    board
        |> filterEmpties
        |> Dict.size


getEmptyCoords : Board -> List Coord
getEmptyCoords board =
    board
        |> filterEmpties
        |> Dict.keys


filterEmpties : Board -> Board
filterEmpties board =
    board |> Dict.filter (\_ tile -> tile == Space Empty)



-- Generate Board


makeBoard : BoardDimensions -> List TileType -> Board
makeBoard scale tiles =
    tiles
        |> List.map (Static >> Space)
        |> List.map2 (,) (makeCoords scale)
        |> Dict.fromList


makeCoords : BoardDimensions -> List Coord
makeCoords { y, x } =
    List.concatMap (rangeToCoord x) (makeRange y)


rangeToCoord : Int -> Int -> List Coord
rangeToCoord y x =
    makeRange y |> List.map (\y -> ( x, y ))


makeRange : Int -> List Int
makeRange n =
    List.range 0 (n - 1)


generateInitialTiles : LevelData -> BoardDimensions -> Cmd Level.Msg
generateInitialTiles levelData { x, y } =
    Random.list (x * y) (tileGenerator levelData.tileSettings)
        |> Random.generate (InitTiles levelData.walls)


seedTypeGenerator : List TileSetting -> Generator SeedType
seedTypeGenerator tileSettings =
    tileSettings
        |> filterSeedSettings
        |> tileGenerator
        |> Random.map (getSeedType >> Maybe.withDefault Sunflower)


filterSeedSettings : List TileSetting -> List TileSetting
filterSeedSettings tileSettings =
    tileSettings |> List.filter (.tileType >> isSeedTile)


tileGenerator : List TileSetting -> Generator TileType
tileGenerator tileSettings =
    Random.int 0 (totalProbability tileSettings) |> Random.map (tileProbability tileSettings)


totalProbability : List TileSetting -> Int
totalProbability tileSettings =
    tileSettings
        |> List.map .probability
        |> List.sum
