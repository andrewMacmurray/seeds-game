module View.Seed.Twin exposing
    ( cornflower
    , lupin
    , marigold
    , sunflower
    )

import Css.Color as Color exposing (Color)
import Svg exposing (Svg)
import Svg.Attributes exposing (..)
import Utils.Svg as Svg


sunflower : Svg msg
sunflower =
    twin ( Color.chocolate, Color.lightBrown )


cornflower : Svg msg
cornflower =
    twin ( Color.midnightBlue, Color.blueGrey )


marigold : Svg msg
marigold =
    twin ( Color.gold, Color.darkRed )


lupin : Svg msg
lupin =
    twin ( Color.crimson, Color.brown )


twin : ( Color, Color ) -> Svg msg
twin ( left, right ) =
    Svg.svg
        [ width "100%"
        , height "100%"
        , Svg.baseTransform
        , viewBox "0 0 124.5 193.5"
        ]
        [ Svg.path
            [ fill left
            , d "M62.33,3.285c0,0-58.047,79.778-58.047,128.616c0,32.059,25.988,58.049,58.047,58.049 c0.057,0,0.113-0.004,0.17-0.004V3.519C62.388,3.365,62.33,3.285,62.33,3.285z"
            ]
            []
        , Svg.path
            [ fill right
            , d "M120.376,131.901c0-47.796-54.445-123.649-57.876-128.383v186.428 C94.479,189.854,120.376,163.903,120.376,131.901z"
            ]
            []
        ]
