module Helpers.Effect exposing (..)

import Delay
import Dom.Scroll exposing (toY)
import Scenes.Hub.Types as Main exposing (..)
import Mouse exposing (downs, moves)
import Task
import Time exposing (millisecond)
import Window exposing (Size, resizes, size)


-- Delay Helpers


sequenceMs : List ( Float, msg ) -> Cmd msg
sequenceMs steps =
    Delay.sequence <| Delay.withUnit millisecond <| steps


trigger : msg -> Cmd msg
trigger msg =
    Delay.after 0 millisecond msg



-- Dom Scroll Helpers


scrollHubToLevel : Float -> Size -> Cmd Main.Msg
scrollHubToLevel offset window =
    let
        targetDistance =
            offset - toFloat (window.height // 2) + 60
    in
        toY "hub" targetDistance |> Task.attempt DomNoOp



-- Window Size helpers


getWindowSize : Cmd Main.Msg
getWindowSize =
    size |> Task.perform WindowSize


trackWindowSize : Sub Main.Msg
trackWindowSize =
    resizes WindowSize



-- Mouse Position Helpers


trackMouseDowns : Sub Main.Msg
trackMouseDowns =
    downs MousePosition


trackMousePosition : Main.Model -> Sub Main.Msg
trackMousePosition model =
    if model.levelModel.isDragging then
        moves MousePosition
    else
        Sub.none
