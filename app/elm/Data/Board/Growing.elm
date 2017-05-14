module Data.Board.Growing exposing (..)

import Data.Moves.Check exposing (coordsList)
import Data.Tiles exposing (growSeedPod, setGrowingToStatic, setToGrowing)
import Dict
import List.Extra exposing (elemIndex)
import Model exposing (..)


handleResetGrowing : Model -> Model
handleResetGrowing model =
    { model | board = resetGrowingTiles model.board }


handleGrowSeedPods : Model -> Model
handleGrowSeedPods model =
    { model | board = growPodsToSeeds model.board }


handleSetGrowingSeedPods : Model -> Model
handleSetGrowingSeedPods model =
    { model | board = setGrowingSeedPods model.currentMove model.board }


resetGrowingTiles : Board -> Board
resetGrowingTiles board =
    board |> Dict.map (\_ tile -> setGrowingToStatic tile)


growPodsToSeeds : Board -> Board
growPodsToSeeds board =
    board |> Dict.map (\_ tile -> growSeedPod tile)


setGrowingSeedPods : List Move -> Board -> Board
setGrowingSeedPods moves board =
    board |> Dict.map (setTileToGrowing moves)


setTileToGrowing : List Move -> Coord -> TileState -> TileState
setTileToGrowing moves coordToCheck tile =
    case elemIndex coordToCheck (coordsList moves) of
        Just i ->
            setToGrowing i tile

        Nothing ->
            tile
