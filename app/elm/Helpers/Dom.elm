module Helpers.Dom exposing (..)

import Dom.Scroll exposing (toY)
import Scenes.Hub.Model exposing (..)
import Task
import Window exposing (Size)


scrollHubToLevel : Float -> Size -> Cmd HubMsg
scrollHubToLevel offset window =
    let
        targetDistance =
            offset - toFloat (window.height // 2) + 60
    in
        toY "hub" targetDistance |> Task.attempt DomNoOp
