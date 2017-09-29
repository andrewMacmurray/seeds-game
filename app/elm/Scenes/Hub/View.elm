module Scenes.Hub.View exposing (..)

import Helpers.Style exposing (backgroundColor, color, heightStyle, widthStyle)
import Html exposing (..)
import Html.Attributes exposing (..)
import Model as Main
import Scenes.Hub.Model as Hub
import Views.Hub.Info exposing (handleHideInfo, info)
import Views.Hub.World exposing (renderWorlds)


hubView : Hub.Model -> Html Main.Msg
hubView model =
    div
        [ class "w-100 fixed overflow-y-scroll momentum-scroll z-2"
        , id "hub"
        , style [ heightStyle model.window.height ]
        , handleHideInfo model
        ]
        (hubContent model)


hubContent : Hub.Model -> List (Html Main.Msg)
hubContent model =
    [ info model ] ++ renderWorlds model
