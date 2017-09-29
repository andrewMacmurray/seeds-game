module Scenes.Hub.View exposing (..)

import Helpers.Style exposing (backgroundColor, color, heightStyle, widthStyle)
import Html exposing (..)
import Html.Attributes exposing (..)
import Model exposing (Msg)
import Scenes.Hub.Model exposing (Model)
import Views.Hub.Info exposing (handleHideInfo, info)
import Views.Hub.World exposing (renderWorlds)
import Window exposing (Size)


hubView : Size -> Model -> Html Msg
hubView window model =
    div
        [ class "w-100 fixed overflow-y-scroll momentum-scroll z-2"
        , id "hub"
        , style [ heightStyle window.height ]
        , handleHideInfo model
        ]
        (hubContent model)


hubContent : Model -> List (Html Msg)
hubContent model =
    [ info model ] ++ renderWorlds model
