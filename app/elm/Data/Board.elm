module Data.Board exposing (..)

import Data.Tiles exposing (evenTiles)
import Random exposing (..)
import Model exposing (..)
import Dict


handleMakeBoard : List Tile -> Model -> Model
handleMakeBoard tileList ({ boardSettings } as model) =
    { model
        | board =
            makeBoard
                boardSettings.sizeX
                boardSettings.sizeY
                tileList
    }


makeBoard : Int -> Int -> List Tile -> Board
makeBoard x y tiles =
    tiles
        |> List.map2 (,) (makeCoords x y)
        |> Dict.fromList


makeCoords : Int -> Int -> List Coord
makeCoords x y =
    List.map (rangeToCoord x) (makeRange y)
        |> List.concat


rangeToCoord : Int -> Int -> List Coord
rangeToCoord x y =
    makeRange x
        |> List.map (\x -> ( x, y ))


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
        |> Random.generate RandomTiles


tileGenerator : Generator Tile
tileGenerator =
    Random.int 1 100
        |> Random.map evenTiles
