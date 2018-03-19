module Data.Board exposing (..)

import Data.Board.Block exposing (Block(Wall), WallColor)
import Dict exposing (Dict)
import Helpers.Dict exposing (mapValues)


type alias Board =
    Dict Coord Block


type alias HasBoard a =
    { a | board : Board }


type alias Move =
    ( Coord, Block )


type alias Coord =
    ( Y, X )


type alias Y =
    Int


type alias X =
    Int


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
