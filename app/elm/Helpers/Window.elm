module Helpers.Window exposing (..)

import Model exposing (..)
import Mouse exposing (downs, moves)
import Task
import Window exposing (resizes, size)


getWindowSize : Cmd Msg
getWindowSize =
    size |> Task.perform WindowSize


trackWindowSize : Sub Msg
trackWindowSize =
    resizes WindowSize


percentWindowHeight : Float -> Model -> Float
percentWindowHeight percent model =
    toFloat model.window.height / 100 * percent


handleMousePosition : Mouse.Position -> Model -> Model
handleMousePosition position model =
    { model | mouse = position }


trackMouseDowns : Sub Msg
trackMouseDowns =
    downs MousePosition


trackMousePosition : Model -> Sub Msg
trackMousePosition model =
    if model.levelModel.isDragging then
        moves MousePosition
    else
        Sub.none
