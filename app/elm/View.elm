module View exposing (..)

import Components.Backdrop exposing (backdrop)
import Html exposing (..)
import Model exposing (..)
import Helpers.Animations exposing (embeddedAnimations)
import Views.Board.Html exposing (handleStop, renderBoard)


view : Model -> Html Msg
view model =
    div (handleStop model)
        [ embeddedAnimations
        , renderBoard model
        , backdrop model
        ]
