module Element.Icon exposing (view)

import Element exposing (..)
import Svg exposing (Svg)


view : List (Attribute msg) -> Svg msg -> Element msg
view attrs =
    html >> el (attributes attrs)


attributes : List (Attribute msg) -> List (Attribute msg)
attributes =
    List.append [ width fill, height fill ]
