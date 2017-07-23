module Data.Board.Falling exposing (..)

import Data.Board.Shift exposing (groupBoardByColumn, handleShiftBoard, shiftBoard, yCoord)
import Data.Tiles exposing (isFalling, isLeaving, setFallingToStatic, setToFalling)
import Dict
import Helpers.Dict exposing (mapValues)
import Model exposing (..)


handleResetFallingTiles : Model -> Model
handleResetFallingTiles model =
    { model | board = model.board |> mapValues setFallingToStatic }


handleFallingTiles : Model -> Model
handleFallingTiles model =
    { model | board = model.board |> updateFallingDistances }


updateFallingDistances : Board -> Board
updateFallingDistances board =
    let
        beforeBoard =
            board
                |> Dict.map (markFallingTile board)

        shiftedBoard =
            beforeBoard
                |> shiftBoard

        tilesToUpdate =
            allNewFallingTiles beforeBoard shiftedBoard
    in
        List.foldl (\( coord, block ) b -> Dict.insert coord block b) beforeBoard tilesToUpdate


allNewFallingTiles : Board -> Board -> List Move
allNewFallingTiles beforeBoard shiftedBoard =
    let
        beforeTiles =
            listsOfFallingTiles beforeBoard

        shiftedTiles =
            listsOfFallingTiles shiftedBoard
    in
        List.map2 newFallingTiles beforeTiles shiftedTiles
            |> List.concat


newFallingTiles : List Move -> List Move -> List Move
newFallingTiles before shifted =
    before
        |> List.map2 (\( ( y1, x1 ), b ) ( ( y2, x2 ), _ ) -> ( ( y2, x2 ), setToFalling (y1 - y2) b )) shifted


listsOfFallingTiles : Board -> List (List Move)
listsOfFallingTiles board =
    board
        |> Dict.filter (\_ b -> isFalling b)
        |> groupBoardByColumn
        |> List.map (List.sortBy yCoord)


markFallingTile : Board -> Coord -> Block -> Block
markFallingTile board coord block =
    if shouldMarkFalling board coord then
        setToFalling 0 block
    else
        block


shouldMarkFalling : Board -> Coord -> Bool
shouldMarkFalling board ( y2, x2 ) =
    board
        |> Dict.filter (\( y1, x1 ) b -> x1 == x2 && isLeaving b && y1 > y2)
        |> (not << Dict.isEmpty)
