module Data.Level.Board.Shift exposing (..)

import Data.Level.Board.Block exposing (isWall)
import Data.Level.Board.Tile exposing (isLeaving)
import Dict
import List.Extra exposing (groupWhile)
import Scenes.Level.Types exposing (..)


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
        |> shiftRemainingTiles


shiftRemainingTiles : List Move -> List Move
shiftRemainingTiles row =
    row
        |> sortByLeaving
        |> List.indexedMap (\i ( _, block ) -> ( ( i, getXfromRow row ), block ))


sortByLeaving : List Move -> List Move
sortByLeaving row =
    let
        walls =
            List.filter (\( _, block ) -> isWall block) row
    in
        row
            |> List.filter (\( _, block ) -> not (isWall block))
            |> List.partition (\( coord, block ) -> isLeaving block)
            |> (\( a, b ) -> a ++ b)
            |> reAddWalls walls


reAddWalls : List Move -> List Move -> List Move
reAddWalls walls row =
    List.foldl addWall row walls


addWall : Move -> List Move -> List Move
addWall (( ( y, x ), w ) as wall) row =
    row
        |> List.Extra.splitAt y
        |> (\( a, b ) -> a ++ [ wall ] ++ b)


getXfromRow : List Move -> Int
getXfromRow coords =
    coords
        |> List.head
        |> Maybe.map Tuple.first
        |> Maybe.map Tuple.second
        |> Maybe.withDefault 0


sameColumn : Move -> Move -> Bool
sameColumn ( ( _, x1 ), _ ) ( ( _, x2 ), _ ) =
    x1 == x2


yCoord : ( Coord, Block ) -> Int
yCoord ( ( y, _ ), _ ) =
    y


xCoord : ( Coord, Block ) -> Int
xCoord ( ( _, x ), _ ) =
    x
