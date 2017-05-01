module View exposing (..)

import Model exposing (..)
import Html exposing (..)
import Components.Backdrop exposing (backdrop)
import Views.Board exposing (renderBoard, handleStop)


view : Model -> Html Msg
view model =
    div (handleStop model)
        [ renderBoard model
        , backdrop model
        ]
