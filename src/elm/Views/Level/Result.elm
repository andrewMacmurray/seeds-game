module Views.Level.Result exposing (..)

import Data.InfoWindow exposing (..)
import Html exposing (..)
import Html.Attributes exposing (class)
import Scenes.Level.Types exposing (..)
import Views.InfoWindow exposing (infoContainer)


infoWindow : LevelModel -> Html msg
infoWindow { hubInfoWindow } =
    let
        infoContent =
            val hubInfoWindow |> Maybe.withDefault ""
    in
    if isHidden hubInfoWindow then
        span [] []
    else
        infoContainer hubInfoWindow <|
            div [ class "pv5 f3 tracked-mega" ] [ text infoContent ]
