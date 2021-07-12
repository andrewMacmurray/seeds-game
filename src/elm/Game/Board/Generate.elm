module Game.Board.Generate exposing
    ( Setting(..)
    , board
    , constantSeed
    , enteringTiles
    , insertEnteringTiles
    , randomSeeds
    )

import Game.Board as Board exposing (Board)
import Game.Board.Block as Block
import Game.Board.Coord exposing (Coord)
import Game.Board.Move as Move exposing (Move)
import Game.Board.Tile exposing (State(..), Tile(..))
import Game.Level.Tile as Tile exposing (Probability(..))
import Random exposing (Generator)
import Seed exposing (Seed)



-- Random Seeds


randomSeeds : (List Tile -> msg) -> Board -> List Tile.Setting -> Cmd msg
randomSeeds msg board_ =
    seedTypeGenerator >> toRandomGrowingTiles msg board_


constantSeed : (List Tile -> msg) -> Board -> Seed -> Cmd msg
constantSeed msg board_ seed =
    constantSeedGenerator seed |> toRandomGrowingTiles msg board_


toRandomGrowingTiles : (List Tile -> msg) -> Board -> Generator Tile -> Cmd msg
toRandomGrowingTiles msg board_ =
    Random.list (numberOfGrowingSeedPods board_) >> Random.generate msg


constantSeedGenerator : Seed -> Generator Tile
constantSeedGenerator =
    Seed >> Random.constant


seedTypeGenerator : List Tile.Setting -> Generator Tile
seedTypeGenerator =
    Tile.seedSettings >> tileGenerator


numberOfGrowingSeedPods : Board -> Int
numberOfGrowingSeedPods =
    Board.filterBlocks Block.isGrowing >> Board.size



-- Generate Entering Tiles


type Setting
    = All
    | Filtered Tile


enteringTiles : (List Tile -> msg) -> Setting -> Board -> List Tile.Setting -> Cmd msg
enteringTiles msg setting board_ tileSettings =
    case setting of
        All ->
            generateEntering msg board_ tileSettings

        Filtered tile ->
            filteredEnteringTiles msg tile board_ tileSettings


filteredEnteringTiles : (List Tile -> msg) -> Tile -> Board -> List Tile.Setting -> Cmd msg
filteredEnteringTiles msg tile board_ tileSettings =
    if List.length tileSettings == 1 then
        generateEntering msg board_ tileSettings

    else
        generateWithoutSettingFor tile msg board_ tileSettings


generateWithoutSettingFor : Tile -> (List Tile -> msg) -> Board -> List Tile.Setting -> Cmd msg
generateWithoutSettingFor tile msg board_ =
    withoutSettingFor tile >> generateEntering msg board_


withoutSettingFor : Tile -> List Tile.Setting -> List Tile.Setting
withoutSettingFor tile =
    List.filter (\setting -> setting.tileType /= tile)


generateEntering : (List Tile -> msg) -> Board -> List Tile.Setting -> Cmd msg
generateEntering msg board_ =
    tileGenerator
        >> Random.list (numberOfEmpties board_)
        >> Random.generate msg


numberOfEmpties : Board -> Int
numberOfEmpties =
    filterEmpties >> Board.size



-- Insert Entering Tiles


insertEnteringTiles : List Tile -> Board -> Board
insertEnteringTiles newTiles board_ =
    Board.placeMoves board_ (newEnteringMoves newTiles board_)


newEnteringMoves : List Tile -> Board -> List Move
newEnteringMoves newTiles =
    emptyCoords >> List.map2 (\tile coord -> Move.move coord (Block.entering tile)) newTiles


emptyCoords : Board -> List Coord
emptyCoords =
    filterEmpties >> Board.coords


filterEmpties : Board -> Board
filterEmpties =
    Board.filterBlocks Block.isEmpty



-- Generate Board


board : (Board -> msg) -> List Tile.Setting -> Board.Size -> Cmd msg
board msg tileSettings ({ x, y } as boardSize) =
    Random.list (x * y) (tileGenerator tileSettings)
        |> Random.map (Board.fromTiles boardSize)
        |> Random.generate msg


tileGenerator : List Tile.Setting -> Generator Tile
tileGenerator tileSettings =
    Random.int 0 (totalProbability tileSettings) |> Random.map (tileProbability tileSettings)



-- Probabilities


totalProbability : List Tile.Setting -> Int
totalProbability =
    List.map .probability
        >> List.map Tile.probability
        >> List.sum


tileProbability : List Tile.Setting -> Int -> Tile
tileProbability tileSettings n =
    tileSettings
        |> List.foldl (evalProbability n) ( Nothing, 0 )
        |> Tuple.first
        |> Maybe.withDefault SeedPod


evalProbability : Int -> Tile.Setting -> ( Maybe Tile, Int ) -> ( Maybe Tile, Int )
evalProbability n { tileType, probability } ( val, accProb ) =
    let
        p =
            Tile.probability probability
    in
    case val of
        Nothing ->
            if n <= p + accProb then
                ( Just tileType, p )

            else
                ( Nothing, p + accProb )

        Just tileType_ ->
            ( Just tileType_, p )
