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
import Data.Board.Block as Block exposing (Block(..))
import Data.Board.Coord exposing (Coord)
import Data.Board.Tile as Tile exposing (SeedType(..), State(..), Type(..))
import Data.Board.Types exposing (..)
import Data.Level.Setting.Tile as Tile exposing (Probability(..))
import Random exposing (Generator)



-- Growing Tiles


insertNewSeeds : Tile.SeedType -> Board -> Board
insertNewSeeds seedType board =
    let
        seedsToAdd =
            board
                |> filterGrowing
                |> Board.moves
                |> List.map (setGrowingSeed seedType)
    in
    Board.placeMoves board seedsToAdd


setGrowingSeed : Tile.SeedType -> Move -> Move
setGrowingSeed seedType ( coord, block ) =
    ( coord
    , Space <| Growing (Seed seedType) <| Block.growingOrder block
    )


generateRandomSeedType : (Tile.SeedType -> msg) -> List Tile.Setting -> Cmd msg
generateRandomSeedType msg =
    seedTypeGenerator >> Random.generate msg


filterGrowing : Board -> Board
filterGrowing =
    Board.filterBlocks Block.isGrowing



-- Entering Tiles


insertNewEnteringTiles : List Tile.Type -> Board -> Board
insertNewEnteringTiles newTiles board =
    let
        tilesToAdd =
            board
                |> getEmptyCoords
                |> List.map2 (\tile coord -> ( coord, Space <| Entering tile )) newTiles
    in
    Board.placeMoves board tilesToAdd


generateEnteringTiles : (List Tile.Type -> msg) -> Board -> List Tile.Setting -> Cmd msg
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


addBlock : Coord -> Tile.Type -> Board -> Board
addBlock coord tileType =
    Board.placeAt coord <| Block.static tileType


mono : Tile.Type -> BoardDimensions -> Board
mono tileType ({ x, y } as scale) =
    Board.fromTiles scale <| List.repeat (x * y) tileType



-- Generate Board


generateInitialTiles : (List Tile.Type -> msg) -> List Tile.Setting -> BoardDimensions -> Cmd msg
generateInitialTiles msg tileSettings { x, y } =
    Random.list (x * y) (tileGenerator tileSettings)
        |> Random.generate msg


seedTypeGenerator : List Tile.Setting -> Generator Tile.SeedType
seedTypeGenerator =
    filterSeedSettings
        >> tileGenerator
        >> Random.map (Tile.getSeedType >> Maybe.withDefault Sunflower)


filterSeedSettings : List Tile.Setting -> List Tile.Setting
filterSeedSettings =
    List.filter (.tileType >> Tile.isSeed)


tileGenerator : List Tile.Setting -> Generator Tile.Type
tileGenerator tileSettings =
    Random.int 0 (totalProbability tileSettings) |> Random.map (tileProbability tileSettings)



-- Probabilities


totalProbability : List Tile.Setting -> Int
totalProbability tileSettings =
    tileSettings
        |> List.map .probability
        |> List.map (\(Probability p) -> p)
        |> List.sum


tileProbability : List Tile.Setting -> Int -> Tile.Type
tileProbability tileSettings n =
    tileSettings
        |> List.foldl (evalProbability n) ( Nothing, 0 )
        |> Tuple.first
        |> Maybe.withDefault SeedPod


evalProbability : Int -> Tile.Setting -> ( Maybe Tile.Type, Int ) -> ( Maybe Tile.Type, Int )
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
