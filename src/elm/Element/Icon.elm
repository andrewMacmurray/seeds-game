module Element.Icon exposing (view)

import Element exposing (..)
import Svg exposing (Svg)


view : List (Svg.Attribute msg) -> List (Svg msg) -> Element msg
view attrs els =
    embed (Svg.svg attrs els)


embed : Svg msg -> Element msg
embed =
    Element.el [] << Element.html
