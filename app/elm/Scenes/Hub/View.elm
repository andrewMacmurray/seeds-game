module Scenes.Hub.View exposing (..)

import Helpers.Style exposing (backgroundColor, color, heightStyle, widthStyle)
import Html exposing (..)
import Html.Attributes exposing (..)
import Model exposing (..)
import Views.Hub.World exposing (renderWorlds)


hub : Model -> Html Msg
hub model =
    div
        [ class "w-100 fixed overflow-y-scroll momentum-scroll z-5"
        , id "hub"
        , style [ heightStyle model.window.height ]
        ]
        (renderWorlds model)
