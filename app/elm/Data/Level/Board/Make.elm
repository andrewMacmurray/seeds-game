module Data.Level.Board.Make exposing (..)

import Data.Level.Board.Probabilities exposing (tileProbability)
import Dict
import Scenes.Hub.Types exposing (LevelData, WorldData)
import Random exposing (..)
import Scenes.Level.Types exposing (..)
import Scenes.Level.Types as Level exposing (Msg(..))


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


generateTiles : LevelData -> Int -> Cmd Level.Msg
generateTiles levelData x =
    Random.list (x * x) (tileGenerator levelData.tileSettings)
        |> Random.generate (InitTiles levelData.walls)


tileGenerator : List TileSetting -> Generator TileType
tileGenerator probabilities =
    Random.int 1 100
        |> Random.map (tileProbability probabilities)
