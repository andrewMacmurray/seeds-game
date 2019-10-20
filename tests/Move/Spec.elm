module Move.Spec exposing (spec)

import Data.Board.Move as Move
import Data.Board.Types exposing (..)
import Expect
import Test exposing (..)


spec : Test
spec =
    describe "Move"
        [ surroundingCoordinatesSpec
        ]


surroundingCoordinatesSpec : Test
surroundingCoordinatesSpec =
    describe "surroundingCoordinates"
        [ describe "with a radius of 1"
            [ test "gets correct number of surrounding coordinates" <|
                \_ ->
                    coord 3 4
                        |> Move.surroundingCoordinates boardDimensions 1
                        |> List.length
                        |> Expect.equal 8
            , test "does not include coordinates out of bounds on the given boardSize" <|
                \_ ->
                    coord 7 7
                        |> Move.surroundingCoordinates boardDimensions 1
                        |> List.length
                        |> Expect.equal 3
            , test "gets correct surrounding coordinates" <|
                \_ ->
                    coord 3 4
                        |> Move.surroundingCoordinates boardDimensions 1
                        |> expectCoordinates
                            [ [ ( 2, 3 ), ( 3, 3 ), ( 4, 3 ) ]
                            , [ ( 2, 4 ), {- 3,4 -} ( 4, 4 ) ]
                            , [ ( 2, 5 ), ( 3, 5 ), ( 4, 5 ) ]
                            ]
            ]
        , describe "with a radius of 2"
            [ test "gets correct number of surrounding coordinates" <|
                \_ ->
                    coord 3 3
                        |> Move.surroundingCoordinates boardDimensions 2
                        |> List.length
                        |> Expect.equal 24
            , test "does not include corrdiantes out of bounds on the given boardSize" <|
                \_ ->
                    coord 7 7
                        |> Move.surroundingCoordinates boardDimensions 2
                        |> List.length
                        |> Expect.equal 8
            , test "gets correct surrounding coordinates" <|
                \_ ->
                    coord 3 4
                        |> Move.surroundingCoordinates boardDimensions 2
                        |> expectCoordinates
                            [ [ ( 1, 2 ), ( 2, 2 ), ( 3, 2 ), ( 4, 2 ), ( 5, 2 ) ]
                            , [ ( 1, 3 ), ( 2, 3 ), ( 3, 3 ), ( 4, 3 ), ( 5, 3 ) ]
                            , [ ( 1, 4 ), ( 2, 4 ), {- 3,4 -} ( 4, 4 ), ( 5, 4 ) ]
                            , [ ( 1, 5 ), ( 2, 5 ), ( 3, 5 ), ( 4, 5 ), ( 5, 5 ) ]
                            , [ ( 1, 6 ), ( 2, 6 ), ( 3, 6 ), ( 4, 6 ), ( 5, 6 ) ]
                            ]
            ]
        ]


expectCoordinates : List (List ( Int, Int )) -> List Coord -> Expect.Expectation
expectCoordinates rawExpectedCoords actualCoords =
    let
        expectedCoords =
            rawExpectedCoords
                |> List.concat
                |> List.map (\( x, y ) -> coord x y)
                |> List.sort
    in
    actualCoords
        |> List.sort
        |> Expect.equal expectedCoords


coord : Int -> Int -> Coord
coord x y =
    ( y, x )


boardDimensions : BoardDimensions
boardDimensions =
    { x = 8
    , y = 8
    }
