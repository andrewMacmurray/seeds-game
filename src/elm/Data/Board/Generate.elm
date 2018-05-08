module Data.Board.Generate
    exposing
        ( generateEnteringTiles
        , generateInitialTiles
        , generateRandomSeedType
        , insertNewEnteringTiles
        , insertNewSeeds
        , makeBoard
        )

import Data.Board.Block as Block
import Data.Board.Tile as Tile
import Data.Board.Types exposing (..)
import Data.Level.Types exposing (..)
import Dict
import Random exposing (Generator)


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
    ( coord, Space <| Growing (Seed seedType) <| Block.growingOrder block )


generateRandomSeedType : (SeedType -> msg) -> List TileSetting -> Cmd msg
generateRandomSeedType msg tileSettings =
    tileSettings
        |> seedTypeGenerator
        |> Random.generate msg


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
    board |> Dict.filter (\_ block -> Block.isGrowing block)



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


generateEnteringTiles : (List TileType -> msg) -> List TileSetting -> Board -> Cmd msg
generateEnteringTiles msg tileSettings board =
    tileGenerator tileSettings
        |> Random.list (numberOfEmpties board)
        |> Random.generate msg


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


generateInitialTiles : (List TileType -> msg) -> List TileSetting -> BoardDimensions -> Cmd msg
generateInitialTiles msg tileSettings { x, y } =
    Random.list (x * y) (tileGenerator tileSettings)
        |> Random.generate msg


seedTypeGenerator : List TileSetting -> Generator SeedType
seedTypeGenerator tileSettings =
    tileSettings
        |> filterSeedSettings
        |> tileGenerator
        |> Random.map (Tile.getSeedType >> Maybe.withDefault Sunflower)


filterSeedSettings : List TileSetting -> List TileSetting
filterSeedSettings tileSettings =
    tileSettings |> List.filter (.tileType >> Tile.isSeed)


tileGenerator : List TileSetting -> Generator TileType
tileGenerator tileSettings =
    Random.int 0 (totalProbability tileSettings) |> Random.map (tileProbability tileSettings)


totalProbability : List TileSetting -> Int
totalProbability tileSettings =
    tileSettings
        |> List.map .probability
        |> List.map (\(Probability p) -> p)
        |> List.sum


tileProbability : List TileSetting -> Int -> TileType
tileProbability tileSettings n =
    tileSettings
        |> List.foldl (handleProb n) ( Nothing, 0 )
        |> Tuple.first
        |> Maybe.withDefault SeedPod


handleProb : Int -> TileSetting -> ( Maybe TileType, Int ) -> ( Maybe TileType, Int )
handleProb n { tileType, probability } ( val, accProb ) =
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

        Just tileType ->
            ( Just tileType, p )
