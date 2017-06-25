module Helpers.Window exposing (..)

import Model exposing (..)
import Task
import Window exposing (size)


getWindowSize : Cmd Msg
getWindowSize =
    size |> Task.perform WindowSize
