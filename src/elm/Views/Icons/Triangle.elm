module Views.Icons.Triangle exposing (..)

import Config.Color exposing (lightGold)
import Svg exposing (Svg)
import Svg.Attributes exposing (..)


triangle : Svg msg
triangle =
    Svg.svg [ height "18", width "18" ]
        [ Svg.path [ d "M9 18l9-18H0z", fill lightGold, fillRule "evenodd" ] [] ]
