module Data.Board.Shift exposing (..)

import Data.Tiles exposing (isLeaving)
import Dict
import List.Extra exposing (groupWhile)
import Model exposing (..)


handleShiftBoard : Model -> Model
handleShiftBoard model =
    { model | board = shiftBoard model.board }


shiftBoard : Board -> Board
shiftBoard board =
    board
        |> groupBoardByColumn
        |> List.concatMap shiftRow
        |> Dict.fromList


groupBoardByColumn : Board -> List (List Move)
groupBoardByColumn board =
    board
        |> Dict.toList
        |> List.sortBy xCoord
        |> groupWhile sameColumn


shiftRow : List Move -> List Move
shiftRow row =
    row
        |> List.sortBy yCoord
        |> List.unzip
        |> shiftRemainingTiles


shiftRemainingTiles : ( List Coord, List TileState ) -> List Move
shiftRemainingTiles ( coords, tiles ) =
    tiles
        |> sortByLeaving
        |> List.indexedMap (\i tile -> ( ( i, getXfromRow coords ), tile ))


sortByLeaving : List TileState -> List TileState
sortByLeaving tiles =
    tiles
        |> List.partition isLeaving
        |> (\( a, b ) -> a ++ b)


getXfromRow : List Coord -> Int
getXfromRow coords =
    coords
        |> List.head
        |> Maybe.map Tuple.second
        |> Maybe.withDefault 0


sameColumn : Move -> Move -> Bool
sameColumn ( ( _, x1 ), _ ) ( ( _, x2 ), _ ) =
    x1 == x2


yCoord : ( Coord, TileState ) -> Int
yCoord ( ( y, _ ), _ ) =
    y


xCoord : ( Coord, TileState ) -> Int
xCoord ( ( _, x ), _ ) =
    x
