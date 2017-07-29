module Helpers.Window exposing (..)

import Scenes.Level.Model exposing (..)
import Mouse exposing (moves)
import Task
import Window exposing (resizes, size)


handleMousePosition : Mouse.Position -> Model -> Model
handleMousePosition position model =
    { model | mouse = position }


percentWindowHeight : Int -> Model -> Int
percentWindowHeight percent model =
    model.window.height // 100 * percent


trackWindowSize : Sub Msg
trackWindowSize =
    resizes WindowSize


getWindowSize : Cmd Msg
getWindowSize =
    size |> Task.perform WindowSize


trackMousePosition : Model -> Sub Msg
trackMousePosition model =
    if model.isDragging then
        moves MousePosition
    else
        Sub.none
