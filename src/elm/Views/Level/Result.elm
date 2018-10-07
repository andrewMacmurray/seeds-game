module Views.Level.Result exposing (renderInfoWindow)

import Data.InfoWindow exposing (..)
import Html exposing (..)
import Html.Attributes exposing (class)
import Scenes.Level.Types exposing (..)
import Views.InfoWindow exposing (infoContainer)


renderInfoWindow : LevelModel -> Html msg
renderInfoWindow { infoWindow } =
    let
        infoContent =
            val infoWindow |> Maybe.withDefault ""
    in
    if isHidden infoWindow then
        span [] []

    else
        infoContainer infoWindow <|
            div [ class "pv5 f3 tracked-mega" ] [ text infoContent ]
