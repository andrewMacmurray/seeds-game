module View exposing (..)

import Components.Backdrop exposing (backdrop)
import Html exposing (..)
import Model exposing (..)
import Views.Board exposing (handleStop, renderBoard)


view : Model -> Html Msg
view model =
    div (handleStop model)
        [ renderBoard model
        , backdrop model
        ]
