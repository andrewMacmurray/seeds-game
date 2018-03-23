module Data.Board.Map
    exposing
        ( mapBlocks
        , mapBoard
        )

import Data.Board.Types exposing (..)
import Helpers.Dict exposing (mapValues)


mapBlocks : (Block -> Block) -> HasBoard model -> HasBoard model
mapBlocks f model =
    { model | board = (mapValues f) model.board }


mapBoard : (Board -> Board) -> HasBoard model -> HasBoard model
mapBoard fn model =
    { model | board = fn model.board }
