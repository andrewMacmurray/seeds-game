module Scenes.Hub.View exposing (..)

import Config.Color exposing (washedYellow)
import Helpers.Style exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Scenes.Hub.Types as Hub
import Views.Hub.InfoWindow exposing (handleHideInfo, info)
import Views.Hub.World exposing (renderWorlds)
import Views.Lives exposing (livesLeft)


hubView : Hub.Model -> Html Hub.Msg
hubView model =
    div
        [ class "w-100 fixed overflow-y-scroll momentum-scroll z-2"
        , id "hub"
        , style [ heightStyle model.window.height ]
        , handleHideInfo model
        ]
        (hubContent model)


hubContent : Hub.Model -> List (Html Hub.Msg)
hubContent model =
    [ info model
    , hubTopBar model
    ]
        ++ renderWorlds model


hubTopBar : Hub.Model -> Html msg
hubTopBar model =
    div
        [ class "fixed w-100 top-0 tc pa3"
        , style [ background washedYellow ]
        ]
        [ div [ style [ transformStyle <| scale 0.8 ] ] <| livesLeft model.lives
        ]
