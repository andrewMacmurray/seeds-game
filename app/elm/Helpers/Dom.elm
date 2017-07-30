module Helpers.Dom exposing (..)

import Dom.Scroll exposing (toBottom)
import Model exposing (..)
import Task


scrollHubToBottom : Cmd Msg
scrollHubToBottom =
    toBottom "hub" |> Task.attempt DomNoOp
