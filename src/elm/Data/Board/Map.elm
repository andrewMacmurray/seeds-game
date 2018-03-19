module Data.Board.Map exposing (..)

import Data.Board.Types exposing (..)
import Dict exposing (Dict)
import Helpers.Dict exposing (mapValues)


addWalls : List ( WallColor, Coord ) -> Board -> Board
addWalls coords board =
    List.foldl
        (\( wallColor, coord ) currentBoard -> Dict.update coord (Maybe.map (always <| Wall wallColor)) currentBoard)
        board
        coords


mapBlocks : (Block -> Block) -> HasBoard model -> HasBoard model
mapBlocks f model =
    { model | board = (mapValues f) model.board }


mapBoard : (Board -> Board) -> HasBoard model -> HasBoard model
mapBoard fn model =
    { model | board = fn model.board }
