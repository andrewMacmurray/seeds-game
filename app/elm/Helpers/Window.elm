module Helpers.Window exposing (..)

import Scenes.Level.Model exposing (..)
import Model as MainModel
import Mouse exposing (moves)


handleMousePosition : Mouse.Position -> Model -> Model
handleMousePosition position model =
    { model | mouse = position }


percentWindowHeight : Int -> MainModel.Model -> Int
percentWindowHeight percent model =
    model.window.height // 100 * percent


trackMousePosition : Model -> Sub Msg
trackMousePosition model =
    if model.isDragging then
        moves MousePosition
    else
        Sub.none
