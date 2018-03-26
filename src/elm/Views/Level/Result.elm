module Views.Level.Result exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class)
import Scenes.Level.Types exposing (..)
import Data.InfoWindow exposing (..)
import Views.InfoWindow exposing (infoContainer)


infoWindow : LevelModel -> Html msg
infoWindow model =
    case model.hubInfoWindow of
        Hidden ->
            span [] []

        Visible message ->
            infoContainer model.hubInfoWindow <|
                div [ class "pv5 f3 tracked-mega" ] [ text message ]

        Hiding message ->
            infoContainer model.hubInfoWindow <|
                div [ class "pv5 f3 tracked-mega" ] [ text message ]
