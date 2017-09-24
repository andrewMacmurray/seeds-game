module Data.Level.Board.Entering exposing (..)

import Data.Level.Board.Make exposing (tileGenerator)
import Dict
import Data.Level.Types exposing (..)
import Random exposing (Generator)


addNewTiles : List TileType -> Board -> Board
addNewTiles newTiles board =
    let
        tilesToAdd =
            board
                |> getEmptyCoords
                |> List.map2 (\tile coord -> ( coord, Space <| Entering tile )) newTiles
                |> Dict.fromList
    in
        Dict.union tilesToAdd board


makeNewTiles : List TileProbability -> Board -> (List TileType -> msg) -> Cmd msg
makeNewTiles prob board msg =
    (tileGenerator prob)
        |> Random.list (numberOfEmpties board)
        |> Random.generate msg


numberOfEmpties : Board -> Int
numberOfEmpties board =
    board
        |> getEmpties
        |> Dict.size


getEmptyCoords : Board -> List Coord
getEmptyCoords board =
    board
        |> getEmpties
        |> Dict.keys


getEmpties : Board -> Board
getEmpties board =
    board |> Dict.filter (\_ tile -> tile == Space Empty)
