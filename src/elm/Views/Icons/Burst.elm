module Views.Icons.Burst exposing
    ( active
    , inactive
    )

import Css.Color as Color
import Css.Style as Style
import Css.Transition as Transition
import Helpers.Svg exposing (..)
import Svg
import Svg.Attributes exposing (..)


active : Color.Color -> Color.Color -> Svg.Svg msg
active =
    burst


inactive : Svg.Svg msg
inactive =
    burst "#807a6e" Color.lightYellow


burst : Color.Color -> Color.Color -> Svg.Svg msg
burst edgeColor centerColor =
    Svg.svg [ viewBox_ 0 0 28 28 ]
        [ Svg.path
            [ d "M14 2l12 12-12 12L2 14 14 2z"
            , fill centerColor
            , stroke edgeColor
            , strokeWidth_ 2
            , strokeLinejoin "round"
            , Style.svgStyle [ Transition.transitionAll 100 [] ]
            ]
            []
        ]
