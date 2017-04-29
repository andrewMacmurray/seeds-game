module View exposing (..)

import Components.Backdrop exposing (backdrop)
import Html exposing (..)
import Types exposing (..)
import Views.Board exposing (renderBoard)


view : Model -> Html Msg
view model =
    div []
        [ renderBoard model
        , backdrop model
        ]
