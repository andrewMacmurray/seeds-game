module Element.Icon.Triangle exposing (icon)

import Css.Color exposing (lightGold)
import Element exposing (Element)
import Element.Icon as Icon
import Svg exposing (Svg)
import Svg.Attributes exposing (..)


icon : Element msg
icon =
    Icon.icon
        (Svg.svg [ height "18", width "18" ]
            [ Svg.path
                [ d "M9 18l9-18H0z"
                , fill lightGold
                , fillRule "evenodd"
                ]
                []
            ]
        )
