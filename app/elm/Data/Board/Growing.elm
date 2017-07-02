module Data.Board.Growing exposing (..)

import Data.Tiles exposing (growSeedPod, setDraggingToGrowing, setGrowingToStatic)
import Dict
import Model exposing (..)


handleResetGrowing : Model -> Model
handleResetGrowing model =
    { model | board = resetGrowingTiles model.board }


handleGrowSeedPods : Model -> Model
handleGrowSeedPods model =
    { model | board = growPodsToSeeds model.board }


handleSetGrowingSeedPods : Model -> Model
handleSetGrowingSeedPods model =
    { model | board = setGrowingSeedPods model.board }


resetGrowingTiles : Board -> Board
resetGrowingTiles board =
    board |> mapKeys setGrowingToStatic


growPodsToSeeds : Board -> Board
growPodsToSeeds board =
    board |> mapKeys growSeedPod


setGrowingSeedPods : Board -> Board
setGrowingSeedPods board =
    board |> mapKeys setDraggingToGrowing


mapKeys : (b -> b) -> Dict.Dict comparable b -> Dict.Dict comparable b
mapKeys f xs =
    Dict.map (\_ x -> f x) xs
