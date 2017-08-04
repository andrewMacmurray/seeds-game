module Helpers.Dom exposing (..)

import Dom.Scroll exposing (toY)
import Model exposing (..)
import Task


scrollHubToLevel : Float -> Model -> Cmd Msg
scrollHubToLevel offset model =
    let
        targetDistance =
            offset - toFloat (model.window.height // 2) + 60
    in
        toY "hub" targetDistance |> Task.attempt DomNoOp
