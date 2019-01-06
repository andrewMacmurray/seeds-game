module Data.Board exposing (replace, update)

import Data.Board.Move as Move
import Data.Board.Types exposing (Block, Board, Coord, Move)
import Dict


update : Coord -> (Block -> Block) -> Board -> Board
update coord f =
    Dict.update coord <| Maybe.map f


replace : Move -> Board -> Board
replace move =
    Dict.update (Move.coord move) <| Maybe.map (always <| Move.block move)
