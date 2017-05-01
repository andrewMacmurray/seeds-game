port module Main exposing (..)

import Test exposing (..)
import Test.Runner.Node exposing (run, TestProgram)
import Json.Encode exposing (Value)
import Board.ShiftSpec as Shift


all : Test
all =
    describe "all tests"
        [ Shift.all ]


main : TestProgram
main =
    run emit all


port emit : ( String, Value ) -> Cmd msg
