module Scenes.Hub.View exposing (..)

import Helpers.Style exposing (backgroundColor, color, heightStyle, widthStyle)
import Html exposing (..)
import Html.Attributes exposing (..)
import Model exposing (..)
import Views.Hub.Info exposing (handleHideInfo, info)
import Views.Hub.World exposing (renderWorlds)


hub : Model -> Html Msg
hub model =
    div []
        [ worlds model
        ]


worlds : Model -> Html Msg
worlds model =
    div
        [ class "w-100 fixed overflow-y-scroll momentum-scroll z-2"
        , id "hub"
        , style [ heightStyle model.window.height ]
        , handleHideInfo model
        ]
        ([ info model ] ++ (renderWorlds model))
