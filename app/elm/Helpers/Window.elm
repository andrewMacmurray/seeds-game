module Helpers.Window exposing (..)

import Model exposing (..)
import Task
import Window exposing (size)


percentWindowHeight : Int -> Model -> Int
percentWindowHeight percent model =
    model.window.height // 100 * percent


getWindowSize : Cmd Msg
getWindowSize =
    size |> Task.perform WindowSize
