module Board.Generate exposing
    ( board
    , enteringTiles
    , generateRandomSeedType
    , insertEnteringTiles
    , insertGrowingSeeds
    , mono
    )

import Board exposing (Board)
import Board.Block as Block exposing (Block(..))
import Board.Coord exposing (Coord)
import Board.Move as Move exposing (Move)
import Board.Tile as Tile exposing (State(..), Tile(..))
import Level.Setting.Tile as Tile exposing (Probability(..))
import Random exposing (Generator)
import Seed exposing (Seed)



-- Growing Tiles


insertGrowingSeeds : Seed.Seed -> Board -> Board
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


generateRandomSeedType : (Seed.Seed -> msg) -> List Tile.Setting -> Cmd msg
generateRandomSeedType msg =
    seedTypeGenerator >> Random.generate msg


filterGrowing : Board -> Board
filterGrowing =
    Board.filterBlocks Block.isGrowing



-- Entering Tiles


insertEnteringTiles : List Tile -> Board -> Board
insertEnteringTiles newTiles board_ =
    let
        tilesToAdd =
            board_
                |> getEmptyCoords
                |> List.map2 (\tile coord -> Move.move coord (Space <| Entering tile)) newTiles
    in
    Board.placeMoves board_ tilesToAdd


enteringTiles : (List Tile -> msg) -> Board -> List Tile.Setting -> Cmd msg
enteringTiles msg board_ tileSettings =
    tileGenerator tileSettings
        |> Random.list (numberOfEmpties board_)
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


mono : Tile -> Board.Size -> Board
mono tileType ({ x, y } as scale) =
    Board.fromTiles scale <| List.repeat (x * y) tileType



-- Generate Board


board : (Board -> msg) -> List Tile.Setting -> Board.Size -> Cmd msg
board msg tileSettings ({ x, y } as boardSize) =
    Random.list (x * y) (tileGenerator tileSettings)
        |> Random.map (Board.fromTiles boardSize)
        |> Random.generate msg


seedTypeGenerator : List Tile.Setting -> Generator Seed
seedTypeGenerator =
    filterSeedSettings
        >> tileGenerator
        >> Random.map (Tile.seedType >> Maybe.withDefault Seed.Sunflower)


filterSeedSettings : List Tile.Setting -> List Tile.Setting
filterSeedSettings =
    List.filter (.tileType >> Tile.isSeed)


tileGenerator : List Tile.Setting -> Generator Tile
tileGenerator tileSettings =
    Random.int 0 (totalProbability tileSettings) |> Random.map (tileProbability tileSettings)



-- Probabilities


totalProbability : List Tile.Setting -> Int
totalProbability tileSettings =
    tileSettings
        |> List.map .probability
        |> List.map (\(Probability p) -> p)
        |> List.sum


tileProbability : List Tile.Setting -> Int -> Tile
tileProbability tileSettings n =
    tileSettings
        |> List.foldl (evalProbability n) ( Nothing, 0 )
        |> Tuple.first
        |> Maybe.withDefault SeedPod


evalProbability : Int -> Tile.Setting -> ( Maybe Tile, Int ) -> ( Maybe Tile, Int )
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
