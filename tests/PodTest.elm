module PodTest exposing (suite)

import Expect
import Game.Board as Board exposing (Board)
import Game.Board.Coord as Coord
import Game.Board.Mechanic.Pod as Pod
import Game.Board.Move as Move
import Game.Board.Move.Move as Move
import Game.Board.Tile exposing (Tile(..))
import Seed exposing (Seed(..))
import Test exposing (..)


suite : Test
suite =
    describe "Pod.isValidNextMove"
        [ test "isValid if previous and next tiles are pods" <|
            \_ ->
                board
                    |> makeMove 0 1
                    |> checkIsValidNextMove 0 2
                    |> Expect.equal True
        , test "isValid if first move is Pod and second is seed" <|
            \_ ->
                board
                    |> makeMove 0 1
                    |> checkIsValidNextMove 1 1
                    |> Expect.equal True
        , test "isNotValid if first move is seed and second is pod" <|
            \_ ->
                board
                    |> makeMove 0 0
                    |> checkIsValidNextMove 1 0
                    |> Expect.equal False
        , test "Can connect a mixture of seeds and pods" <|
            \_ ->
                board
                    |> makeMove 0 1
                    |> makeMove 1 1
                    |> checkIsValidNextMove 1 0
                    |> Expect.equal True
        , test "Can only connect with seeds of one type" <|
            \_ ->
                board
                    |> makeMove 0 1
                    |> makeMove 1 1
                    |> makeMove 1 0
                    |> checkIsValidNextMove 2 0
                    |> Expect.equal False
        ]


makeMove : Coord.X -> Coord.Y -> Board.Board -> Board.Board
makeMove x y board_ =
    Move.drag boardSize (moveFromCoord x y board_) board_


checkIsValidNextMove : Coord.X -> Coord.Y -> Board.Board -> Bool
checkIsValidNextMove x y board_ =
    Pod.isValidNextMove (moveFromCoord x y board_) board_


moveFromCoord : Coord.X -> Coord.Y -> Board.Board -> Move.Move
moveFromCoord x y board_ =
    let
        coord =
            Coord.fromXY x y
    in
    Board.findBlockAt coord board_
        |> Maybe.map (Move.move coord)
        |> Maybe.withDefault Move.empty


board : Board
board =
    toBoard
        [ [ s, p, c, p ]
        , [ p, s, s, p ]
        , [ p, p, s, s ]
        , [ p, s, p, s ]
        ]


toBoard : List (List Tile) -> Board
toBoard =
    Board.fromTiles boardSize << List.concat


boardSize : Board.Size
boardSize =
    { x = 4, y = 4 }


s : Tile
s =
    Seed Sunflower


c : Tile
c =
    Seed Chrysanthemum


p : Tile
p =
    SeedPod
