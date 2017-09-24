module Scenes.Hub exposing (..)

import Helpers.Style exposing (backgroundColor, color, heightStyle, widthStyle)
import Html exposing (..)
import Html.Attributes exposing (..)
import Model exposing (..)
import Views.Hub.Info exposing (handleHideInfo, info)
import Views.Hub.World exposing (renderWorlds)


-- Hub State in top level Update


hubView : Model -> Html Msg
hubView model =
    div
        [ class "w-100 fixed overflow-y-scroll momentum-scroll z-2"
        , id "hub"
        , style [ heightStyle model.window.height ]
        , handleHideInfo model
        ]
        (hubContent model)


hubContent : Model -> List (Html Msg)
hubContent model =
    [ info model ] ++ renderWorlds model
