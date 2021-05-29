module Element.Icon exposing (icon)

import Element exposing (Element, html)
import Svg exposing (Svg)


icon : Svg msg -> Element msg
icon =
    html
