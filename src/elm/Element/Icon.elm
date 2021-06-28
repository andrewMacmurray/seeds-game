module Element.Icon exposing
    ( Dual
    , dual
    , el
    )

import Element exposing (..)
import Svg exposing (Svg)
import Utils.Svg as Svg


type alias Dual msg =
    { el : Element msg
    , svg : Svg msg
    }


dual : List (Svg.Attribute msg) -> List (Svg msg) -> Dual msg
dual attrs els =
    { el = el attrs els
    , svg = Svg.full attrs els
    }


el : List (Svg.Attribute msg) -> List (Svg msg) -> Element msg
el attrs els =
    Element.html (Svg.svg attrs els)
