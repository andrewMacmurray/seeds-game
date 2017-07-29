module Data.Board.Growing exposing (..)

import Data.Tile exposing (growSeedPod, setDraggingToGrowing, setGrowingToStatic)
import Helpers.Dict exposing (mapValues)
import Scenes.Level.Model exposing (..)


handleResetGrowing : Model -> Model
handleResetGrowing model =
    { model | board = model.board |> mapValues setGrowingToStatic }


handleGrowSeedPods : Model -> Model
handleGrowSeedPods model =
    { model | board = model.board |> mapValues growSeedPod }


handleSetGrowingSeedPods : Model -> Model
handleSetGrowingSeedPods model =
    { model | board = model.board |> mapValues setDraggingToGrowing }
