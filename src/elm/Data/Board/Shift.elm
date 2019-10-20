module Data.Board.Shift exposing (groupBoardByColumn, shiftBoard)

import Data.Board as Board
import Data.Board.Block as Block
import Data.Board.Coord as Coord
import Data.Board.Move as Move
import Data.Board.Types exposing (..)
import Helpers.List


shiftBoard : Board -> Board
shiftBoard =
    groupBoardByColumn
        >> List.concatMap shiftRow
        >> Board.fromMoves


groupBoardByColumn : Board -> List (List Move)
groupBoardByColumn =
    Board.moves
        >> List.sortBy Move.x
        >> Helpers.List.groupWhile sameColumn


shiftRow : List Move -> List Move
shiftRow =
    List.sortBy Move.y >> shiftRemainingTiles


shiftRemainingTiles : List Move -> List Move
shiftRemainingTiles row =
    let
        x =
            getXfromRow row

        shiftMove y move =
            ( Coord.fromXY x y, Move.block move )
    in
    row
        |> sortByLeaving
        |> List.indexedMap shiftMove


sortByLeaving : List Move -> List Move
sortByLeaving row =
    let
        isWall =
            Move.block >> Block.isWall

        walls =
            List.filter isWall row

        recombine =
            recombineAround []
    in
    row
        |> List.filter (not << isWall)
        |> List.partition (Move.block >> Block.isLeaving)
        |> recombine
        |> reInsertMoves walls


reInsertMoves : List Move -> List Move -> List Move
reInsertMoves walls row =
    List.foldl insertMove row walls


insertMove : Move -> List Move -> List Move
insertMove move =
    Helpers.List.splitAt (Move.y move) >> recombineAround [ move ]


getXfromRow : List Move -> Int
getXfromRow =
    List.head
        >> Maybe.map Move.x
        >> Maybe.withDefault 0


recombineAround : List a -> ( List a, List a ) -> List a
recombineAround c ( a, b ) =
    a ++ c ++ b


sameColumn : Move -> Move -> Bool
sameColumn m1 m2 =
    Move.x m1 == Move.x m2
