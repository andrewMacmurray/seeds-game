module Utils.Window exposing (..)

import Model exposing (..)
import Task
import Utils.Style exposing (px)
import Window exposing (size)


boardOffsetTop : Model -> ( String, String )
boardOffsetTop model =
    let
        offset =
            (toFloat model.window.height - boardHeight model) / 2
    in
        ( "margin-top", px offset )


boardHeight : Model -> Float
boardHeight model =
    model.tileSettings.sizeY * toFloat model.boardSettings.sizeY


getWindowSize : Cmd Msg
getWindowSize =
    size |> Task.perform WindowSize
