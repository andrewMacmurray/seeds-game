module Views.Intro.BloomingFlowers exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Scenes.Intro.Types exposing (Visibility)
import Views.Flowers.Sunflower exposing (sunflower)
import Views.Intro.RollingHills exposing (rollingHills)


bloomingFlowers : Visibility -> Html msg
bloomingFlowers vis =
    div []
        [ div [ class "flex relative z-2" ]
            [ sunflower 0 ]
        , div [ class "fixed w-100 bottom-0 left-0 z-1" ] [ rollingHills vis ]
        ]
