module Data.Board.Entering exposing (..)

import Data.Board.Make exposing (tileGenerator)
import Data.Tiles exposing (setEnteringToStatic)
import Dict
import Model exposing (..)
import Random exposing (Generator)


handleResetEntering : Model -> Model
handleResetEntering model =
    { model | board = resetEnteringTiles model.board }


handleAddNewTiles : List Tile -> Model -> Model
handleAddNewTiles tileList model =
    { model | board = addNewTiles tileList model.board }


resetEnteringTiles : Board -> Board
resetEnteringTiles board =
    board |> Dict.map (\coord tile -> setEnteringToStatic tile)


addNewTiles : List Tile -> Board -> Board
addNewTiles newTiles board =
    let
        tilesToAdd =
            board
                |> getEmpties
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
        |> List.length


getEmpties : Board -> List Coord
getEmpties board =
    board
        |> Dict.toList
        |> List.filter (\( _, tile ) -> tile == Empty)
        |> List.map Tuple.first
