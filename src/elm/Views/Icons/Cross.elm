module Views.Icons.Cross exposing (cross)

import Css.Color as Color
import Helpers.Svg exposing (..)
import Svg exposing (Svg)
import Svg.Attributes exposing (..)


cross : Svg msg
cross =
    Svg.svg [ viewBox_ 0 0 45 45 ]
        [ Svg.path [ d "M41 .8c-1.1-1-2.8-1-3.9 0L.8 37.1c-1 1-1 2.8 0 3.8l1.8 1.9c1.1 1 2.8 1 3.9 0L42.8 6.5c1-1.1 1-2.8 0-3.8L40.9.8z", fill Color.white ] []
        , Svg.path [ d "M3.5.8c1-1 2.8-1 3.8 0L43.7 37c1 1 1 2.8 0 3.8l-1.9 1.9c-1 1-2.8 1-3.8 0L1.7 6.4c-1-1-1-2.7 0-3.8L3.5.8z", fill Color.white ] []
        ]
