module Scenes.Hub.View exposing (..)

import Helpers.Style exposing (backgroundColor, color, heightStyle, widthStyle)
import Html exposing (..)
import Html.Attributes exposing (..)
import Model exposing (Msg)
import Scenes.Hub.Model exposing (HubModel)
import Views.Hub.Info exposing (handleHideInfo, info)
import Views.Hub.World exposing (renderWorlds)
import Window exposing (Size)


hubView : Size -> HubModel -> Html Msg
hubView window model =
    div
        [ class "w-100 fixed overflow-y-scroll momentum-scroll z-2"
        , id "hub"
        , style [ heightStyle window.height ]
        , handleHideInfo model
        ]
        (hubContent model)


hubContent : HubModel -> List (Html Msg)
hubContent model =
    [ info model ] ++ renderWorlds model
