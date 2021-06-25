module Element.Icon exposing (view)

import Element exposing (..)
import Svg exposing (Svg)


view : List (Svg.Attribute msg) -> List (Svg msg) -> Element msg
view attrs els =
    Element.html (Svg.svg attrs els)
