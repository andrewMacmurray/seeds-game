module Element.Seed.Mono exposing (seed)

import Element exposing (Attribute, Color, Element)
import Element.Icon as Icon
import Svg exposing (Svg)
import Svg.Attributes exposing (..)
import Utils.Color as Color


type alias Options =
    { color : Color
    }


seed : Options -> Element msg
seed options =
    Icon.view []
        (Svg.svg
            [ width "100%"
            , height "100%"
            , viewBox "0 0 124.5 193.5"
            ]
            [ Svg.path
                [ fill (Color.toString options.color)
                , d "M121.004,131.87c0,32.104-26.024,58.13-58.13,58.13c-32.1,0-58.123-26.026-58.123-58.13 c0-48.907,58.123-128.797,58.123-128.797S121.004,82.451,121.004,131.87z"
                ]
                []
            ]
        )
