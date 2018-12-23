module Views.Icons.Burst exposing
    ( active
    , inactive
    )

import Css.Color as Color
import Helpers.Svg exposing (..)
import Svg
import Svg.Attributes exposing (..)


active =
    burst


inactive =
    burst (Color.rgb 234 234 234) Color.transparent


burst edgeColor centerColor =
    Svg.svg [ viewBox_ 0 0 28 28 ]
        [ Svg.path
            [ d "M14 2l12 12-12 12L2 14 14 2z"
            , fill centerColor
            , stroke edgeColor
            , strokeWidth "2"
            , strokeLinejoin "round"
            ]
            []
        ]
