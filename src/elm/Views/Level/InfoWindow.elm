module Views.Level.InfoWindow exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class)
import Scenes.Level.Types exposing (..)
import Data.InfoWindow exposing (..)
import Views.InfoWindow exposing (infoContainer)


infoWindow : Model -> Html msg
infoWindow model =
    case model.levelInfoWindow of
        Hidden ->
            span [] []

        Visible message ->
            infoContainer model.levelInfoWindow <|
                div [ class "pv5 f3 tracked-mega" ] [ text message ]

        Hiding message ->
            infoContainer model.levelInfoWindow <|
                div [ class "pv5 f3 tracked-mega" ] [ text message ]
