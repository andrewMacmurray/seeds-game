module Data.Board.Entering exposing (..)

import Data.Board.Make exposing (tileGenerator)
import Data.Tiles exposing (setEnteringToStatic)
import Dict
import Helpers.Dict exposing (mapValues)
import Model exposing (..)
import Random exposing (Generator)


handleResetEntering : Model -> Model
handleResetEntering model =
    { model | board = model.board |> mapValues setEnteringToStatic }


handleAddNewTiles : List TileType -> Model -> Model
handleAddNewTiles tileList model =
    { model | board = addNewTiles tileList model.board }


addNewTiles : List TileType -> Board -> Board
addNewTiles newTiles board =
    let
        tilesToAdd =
            board
                |> getEmptyCoords
                |> List.map2 (\tile coord -> ( coord, Entering tile )) newTiles
                |> Dict.fromList
    in
        Dict.union tilesToAdd board


makeNewTiles : Board -> Cmd Msg
makeNewTiles board =
    Random.list (numberOfEmpties board) tileGenerator
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
    board |> Dict.filter (\_ tile -> tile == Empty)
