module Data.Board.Make exposing (..)

import Data.Board.Probabilities exposing (tileProbability)
import Dict
import Model exposing (LevelData)
import Random exposing (..)
import Scenes.Level.Model exposing (..)


handleMakeBoard : List TileType -> Model -> Model
handleMakeBoard tileList ({ boardSettings } as model) =
    { model
        | board =
            makeBoard
                boardSettings.sizeX
                boardSettings.sizeY
                tileList
    }


makeBoard : Int -> Int -> List TileType -> Board
makeBoard y x tiles =
    tiles
        |> List.map (Static >> Space)
        |> List.map2 (,) (makeCoords y x)
        |> Dict.fromList


makeCoords : Int -> Int -> List Coord
makeCoords y x =
    List.concatMap (rangeToCoord y) (makeRange x)


rangeToCoord : Int -> Int -> List Coord
rangeToCoord y x =
    makeRange y
        |> List.map (\y -> ( x, y ))


makeRange : Int -> List Int
makeRange n =
    List.range 0 (n - 1)


handleGenerateTiles : LevelData -> Model -> Cmd Msg
handleGenerateTiles levelData { boardSettings } =
    generateTiles
        levelData
        boardSettings.sizeX
        boardSettings.sizeY


generateTiles : LevelData -> Int -> Int -> Cmd Msg
generateTiles levelData x y =
    Random.list (x * y) (tileGenerator levelData.tileProbabilities)
        |> Random.generate (InitTiles levelData.walls)


tileGenerator : List TileProbability -> Generator TileType
tileGenerator probabilities =
    Random.int 1 100
        |> Random.map (tileProbability probabilities)
