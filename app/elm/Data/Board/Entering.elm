module Data.Board.Entering exposing (..)

import Data.Board.Make exposing (tileGenerator)
import Dict
import Scenes.Level.Model exposing (..)
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


makeNewTiles : Model -> Cmd Msg
makeNewTiles model =
    (tileGenerator model.tileProbabilities)
        |> Random.list (numberOfEmpties model.board)
        |> Random.generate AddTiles


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
