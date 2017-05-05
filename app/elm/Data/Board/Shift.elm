module Data.Board.Shift exposing (..)

import Data.Tiles exposing (isLeaving, setToLeaving)
import Dict
import List.Extra exposing (elemIndex, groupWhile)
import Model exposing (..)


handleLeavingTiles : Model -> Model
handleLeavingTiles model =
    let
        newBoard =
            model.board
                |> setLeavingTiles model.currentMove
    in
        { model | board = newBoard }


shiftBoard : Board -> Board
shiftBoard board =
    board
        |> Dict.toList
        |> List.sortBy xCoord
        |> groupWhile sameColumn
        |> List.concatMap shiftRow
        |> Dict.fromList


shiftRow : List Move -> List Move
shiftRow row =
    row
        |> List.sortBy yCoord
        |> List.unzip
        |> shiftLeavingTiles


shiftLeavingTiles : ( List Coord, List TileState ) -> List Move
shiftLeavingTiles ( coords, tiles ) =
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


setLeavingTiles : List Move -> Board -> Board
setLeavingTiles moves board =
    board |> Dict.map (setTileToLeaving moves)


setTileToLeaving : List Move -> Coord -> TileState -> TileState
setTileToLeaving moves coordToCheck tile =
    case elemIndex coordToCheck (coordsList moves) of
        Just i ->
            setToLeaving i tile

        Nothing ->
            tile


coordsList : List Move -> List Coord
coordsList moves =
    moves |> List.map Tuple.first
