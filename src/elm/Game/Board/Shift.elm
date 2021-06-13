module Game.Board.Shift exposing (groupBoardByColumn, shift)

import Game.Board as Board exposing (Board)
import Game.Board.Block as Block
import Game.Board.Coord as Coord
import Game.Board.Move as Move exposing (Move)
import Utils.List


shift : Board -> Board
shift =
    groupBoardByColumn
        >> List.concatMap shiftRow
        >> Board.fromMoves


groupBoardByColumn : Board -> List (List Move)
groupBoardByColumn =
    Board.moves
        >> List.sortBy Move.x
        >> Utils.List.groupWhile sameColumn


shiftRow : List Move -> List Move
shiftRow =
    List.sortBy Move.y >> shiftRemainingTiles


shiftRemainingTiles : List Move -> List Move
shiftRemainingTiles row =
    let
        x =
            getXfromRow row

        shiftMove y move =
            Move.move (Coord.fromXY x y) (Move.block move)
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
    Utils.List.splitAt (Move.y move) >> recombineAround [ move ]


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
