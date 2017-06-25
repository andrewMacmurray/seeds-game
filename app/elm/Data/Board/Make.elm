module Data.Board.Make exposing (..)

import Model exposing (..)
import Data.Tiles exposing (evenTiles)
import Random exposing (..)
import Dict


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
        |> List.map Static
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


handleGenerateTiles : Model -> Cmd Msg
handleGenerateTiles { boardSettings } =
    generateTiles
        boardSettings.sizeX
        boardSettings.sizeY


generateTiles : Int -> Int -> Cmd Msg
generateTiles x y =
    Random.list (x * y) tileGenerator
        |> Random.generate InitTiles


tileGenerator : Generator TileType
tileGenerator =
    Random.int 1 100
        |> Random.map evenTiles
