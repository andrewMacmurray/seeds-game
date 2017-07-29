module View exposing (..)

import Components.Backdrop exposing (backdrop)
import Helpers.Animation exposing (embeddedAnimations)
import Html exposing (..)
import Model exposing (..)
import Views.Level exposing (level)


view : Model -> Html Msg
view model =
    div []
        [ embeddedAnimations
        , level model
        , backdrop model
        ]
