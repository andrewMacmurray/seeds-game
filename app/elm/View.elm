module View exposing (..)

import Views.Backdrop exposing (backdrop)
import Helpers.Animation exposing (embeddedAnimations)
import Html exposing (..)
import Model exposing (..)
import Scene.Level.View exposing (level)


view : Model -> Html Msg
view model =
    div []
        [ embeddedAnimations
        , level model
        , backdrop model
        ]
