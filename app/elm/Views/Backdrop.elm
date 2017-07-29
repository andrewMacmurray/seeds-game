module Views.Backdrop exposing (backdrop)

import Html exposing (..)
import Html.Attributes exposing (..)
import Scenes.Level.Model exposing (..)
import Views.Level.Board exposing (handleStop)


backdrop : Model -> Html Msg
backdrop model =
    div
        [ class "fixed w-100 h-100 top-0 left-0 z-0 bg-yellow"
        , handleStop model
        ]
        []
