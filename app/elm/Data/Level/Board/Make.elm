module Data.Level.Board.Make exposing (..)

import Data.Level.Board.Probabilities exposing (tileProbability)
import Dict
import Data.Hub.Types exposing (LevelData, WorldData)
import Random exposing (..)
import Data.Level.Types exposing (..)


makeBoard : Int -> List TileType -> Board
makeBoard scale tiles =
    tiles
        |> List.map (Static >> Space)
        |> List.map2 (,) (makeCoords scale)
        |> Dict.fromList


makeCoords : Int -> List Coord
makeCoords x =
    List.concatMap (rangeToCoord x) (makeRange x)


rangeToCoord : Int -> Int -> List Coord
rangeToCoord y x =
    makeRange y |> List.map (\y -> ( x, y ))


makeRange : Int -> List Int
makeRange n =
    List.range 0 (n - 1)


generateTiles : LevelData -> Int -> (List Coord -> List TileType -> msg) -> Cmd msg
generateTiles levelData x msg =
    Random.list (x * x) (tileGenerator levelData.tileProbabilities)
        |> Random.generate (msg levelData.walls)


tileGenerator : List TileProbability -> Generator TileType
tileGenerator probabilities =
    Random.int 1 100
        |> Random.map (tileProbability probabilities)
