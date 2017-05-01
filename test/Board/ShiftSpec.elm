module Board.ShiftSpec exposing (..)

import Expect
import Test exposing (..)
import Board.Helpers exposing (..)
import Model exposing (..)
import Data.Board.Shift exposing (..)


all : Test
all =
    describe "shiftSpec suite"
        [ removeTilesSpec
        , convertToBlankSpec
        ]


shiftBoardSpec : Test
shiftBoardSpec =
    describe "shiftBoard"
        [ test "shifts tiles to bottom and blanks to top" <|
            \() ->
                shiftBoard boardAfterMove1
                    |> Expect.equal expectedShiftedBoard
        ]


removeTilesSpec : Test
removeTilesSpec =
    describe "removeTiles"
        [ test "turns move tiles on board blank" <|
            \() ->
                removeTiles dummyValidMove1 dummyBoard
                    |> Expect.equal boardAfterMove1
        ]


convertToBlankSpec : Test
convertToBlankSpec =
    describe "convertToBlank"
        [ test "if coord is in the current move turns tile blank" <|
            \() ->
                convertToBlank dummyValidMove1 ( 3, 0 ) Sun
                    |> Expect.equal Blank
        , test "returns original tile if coord is not in move" <|
            \() ->
                convertToBlank dummyValidMove1 ( 1, 3 ) Rain
                    |> Expect.equal Rain
        ]
