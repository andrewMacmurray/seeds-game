module Views.Level.Result exposing (..)

import Data.InfoWindow exposing (..)
import Html exposing (..)
import Html.Attributes exposing (class)
import Scenes.Level.Types exposing (..)
import Views.InfoWindow exposing (infoContainer)


infoWindow : LevelModel -> Html msg
infoWindow { infoWindow } =
    let
        infoContent =
            val infoWindow |> Maybe.withDefault ""
    in
    if isHidden infoWindow then
        span [] []
    else
        infoContainer infoWindow <|
            div [ class "pv5 f3 tracked-mega" ] [ text infoContent ]
