module Element.Seed.Mono exposing (seed)

import Element exposing (Color)
import Element.Icon as Icon
import Svg
import Svg.Attributes exposing (..)
import Utils.Color as Color
import Utils.Svg as Svg



-- Mono Seed


type alias Options =
    { color : Color
    }


seed : Options -> Icon.Dual msg
seed options =
    Icon.dual
        [ Svg.viewBox_ 0 0 124 193
        , Svg.fullWidth
        ]
        [ Svg.path
            [ fill (Color.toString options.color)
            , d "M121.004,131.87c0,32.104-26.024,58.13-58.13,58.13c-32.1,0-58.123-26.026-58.123-58.13 c0-48.907,58.123-128.797,58.123-128.797S121.004,82.451,121.004,131.87z"
            ]
            []
        ]
