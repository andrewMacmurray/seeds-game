module Board.ShiftSpec exposing (..)

import Board.Helpers exposing (..)
import Data.Board.Shift exposing (..)
import Expect
import List.Extra exposing (getAt)
import Model exposing (..)
import Test exposing (..)


all : Test
all =
    describe "shiftSpec suite"
        [ shiftBoardSpec
        , shiftRowSpec
        , sortByLeavingSpec
        ]


shiftBoardSpec : Test
shiftBoardSpec =
    describe "shiftBoard"
        [ test "shifts leaving tiles correctly in board" <|
            \() ->
                shiftBoard boardBefore
                    |> Expect.equal boardAfter
        ]


shiftRowSpec : Test
shiftRowSpec =
    describe "shiftRow"
        [ test "moves the tiles to the beginning of the list but keeps coords same" <|
            \() ->
                shiftRow (tileRow3 |> addCoords 0)
                    |> List.head
                    |> Expect.equal (Just ( ( 0, 0 ), Leaving Sun 0 ))
        , test "moves the tiles to the beginning of the list but keeps coords same" <|
            \() ->
                shiftRow (tileRow3 |> addCoords 0)
                    |> (getAt 1)
                    |> Expect.equal (Just ( ( 1, 0 ), Leaving Sun 1 ))
        , test "leaves row as is if no leaving tiles" <|
            \() ->
                shiftRow (tileRow2 |> addCoords 0)
                    |> Expect.equal (tileRow2 |> addCoords 0)
        ]


sortByLeavingSpec : Test
sortByLeavingSpec =
    describe "sortByLeaving"
        [ test "moves leaving tiles to the beginning of a list" <|
            \() ->
                sortByLeaving tileRow3
                    |> List.head
                    |> Expect.equal (Just (Leaving Sun 0))
        , test "leaves row as is if no leaving tiles" <|
            \() ->
                sortByLeaving tileRow2
                    |> Expect.equal tileRow2
        ]
