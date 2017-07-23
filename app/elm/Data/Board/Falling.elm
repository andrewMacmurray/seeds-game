module Data.Board.Falling exposing (..)

import Data.Board.Shift exposing (yCoord)
import Data.Tiles exposing (isFalling, isLeaving, setFallingToStatic, setToFalling)
import Dict
import Helpers.Dict exposing (mapValues)
import Model exposing (..)


handleResetFallingTiles : Model -> Model
handleResetFallingTiles model =
    { model | board = model.board |> mapValues setFallingToStatic }


handleFallingTiles : Model -> Model
handleFallingTiles model =
    { model | board = model.board |> Dict.map (markFallingTile model.board) }


markFallingTile : Board -> Coord -> Block -> Block
markFallingTile board coord block =
    let
        fallingDistance =
            tileFallingDistance ( coord, block ) board
    in
        if fallingDistance > 0 then
            setToFalling fallingDistance block
        else
            block


tileFallingDistance : Move -> Board -> Int
tileFallingDistance (( ( y2, x2 ), b ) as move) board =
    let
        fd =
            board
                |> Dict.filter (\( y1, x1 ) block -> x2 == x1 && isLeaving block && y1 > y2)
                |> Dict.size

        wbh =
            wallsBehind fd move board

        wif =
            wallsInFront fd move board
    in
        if nextIsWall ( ( y2 + fd, x2 ), b ) board then
            fd + wbh + wif
        else
            fd + wbh


fallingTilesInFront : Int -> Move -> Board -> Int
fallingTilesInFront hlt (( ( y, x ), _ ) as move) board =
    board
        |> Dict.filter (\( y1, x1 ) block -> x == x1 && block /= Wall && not (isLeaving block) && y1 > y && y1 < hlt)
        |> Dict.size


wallsBehind : Int -> Move -> Board -> Int
wallsBehind fd (( ( y, x ), _ ) as move) board =
    board
        |> Dict.filter (\( y1, x1 ) block -> x == x1 && block == Wall && y1 <= y + fd && y1 > y)
        |> Dict.size


wallsInFront : Int -> Move -> Board -> Int
wallsInFront fd (( ( y, x ), _ ) as move) board =
    let
        ( y2, x2 ) =
            getHighestLeavingTile move board
                |> Maybe.map Tuple.first
                |> Maybe.withDefault ( 0, 0 )

        fif =
            fallingTilesInFront y2 move board
                |> Debug.log (toString ( y, x ))
    in
        board
            |> Dict.filter (\( y1, x1 ) block -> x1 == x && block == Wall && y1 > y + fd && y1 <= (y2 - fif))
            -- |> Debug.log (toString ( y, x ))
            |>
                Dict.size


nextIsWall : Move -> Board -> Bool
nextIsWall ( ( y, x ), _ ) board =
    board
        |> Dict.get ( y + 1, x )
        |> Maybe.map ((==) Wall)
        |> Maybe.withDefault False



-- need to check the number of walls between the original and the falling distance (including fd tile)
-- then if the next one is a wall add the number of walls between the fd and the highest leaving tile (minus the number of falling tiles in front of the target tile)


getHighestLeavingTile : Move -> Board -> Maybe Move
getHighestLeavingTile ( ( y2, x2 ), _ ) board =
    board
        |> Dict.filter (\( y1, x1 ) b -> x2 == x1 && isLeaving b)
        |> Dict.toList
        |> List.sortBy yCoord
        |> List.head



-- exRow =
--     [ ( ( 0, 7 ), Space (Static SeedPod) )
--     , ( ( 1, 7 ), Space (Static Seed) )
--     , ( ( 2, 7 ), Wall )
--     , ( ( 3, 7 ), Space (Static SeedPod) )
--     , ( ( 4, 7 ), Wall )
--     , ( ( 5, 7 ), Space (Leaving SeedPod 1) )
--     , ( ( 6, 7 ), Space (Leaving Seed 2) )
--     , ( ( 7, 7 ), Space (Static Seed) )
--     ]
