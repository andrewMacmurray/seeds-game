module Board.Generate exposing
    ( Setting(..)
    , board
    , enteringTiles
    , insertEnteringTiles
    , randomSeedType
    )

import Board exposing (Board)
import Board.Block as Block exposing (Block(..))
import Board.Coord exposing (Coord)
import Board.Move as Move exposing (Move)
import Board.Tile as Tile exposing (State(..), Tile(..))
import Level.Setting.Tile as Tile exposing (Probability(..))
import Random exposing (Generator)
import Seed exposing (Seed)



-- Random Seeds


randomSeedType : (Seed.Seed -> msg) -> List Tile.Setting -> Cmd msg
randomSeedType msg =
    seedTypeGenerator >> Random.generate msg


seedTypeGenerator : List Tile.Setting -> Generator Seed
seedTypeGenerator =
    filterSeedSettings
        >> tileGenerator
        >> Random.map (Tile.seedType >> Maybe.withDefault Seed.Sunflower)


filterSeedSettings : List Tile.Setting -> List Tile.Setting
filterSeedSettings =
    List.filter (.tileType >> Tile.isSeed)



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
    let
        tilesToAdd =
            board_
                |> emptyCoords
                |> List.map2 (\tile coord -> Move.move coord (Space <| Entering tile)) newTiles
    in
    Board.placeMoves board_ tilesToAdd


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
        >> List.map (\(Probability p) -> p)
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
