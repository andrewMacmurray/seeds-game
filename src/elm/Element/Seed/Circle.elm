module Element.Seed.Circle exposing (seed)

import Element exposing (Color)
import Element.Icon as Icon
import Svg
import Svg.Attributes exposing (..)
import Utils.Color as Color
import Utils.Svg as Svg



-- Circle Seed


type alias Options =
    { background : Color
    , center : Color
    }


seed : Options -> Icon.Dual msg
seed options =
    Icon.dual
        [ Svg.viewBox_ 0 0 124 193
        , Svg.fullWidth
        ]
        [ Svg.path
            [ fill (Color.toString options.background)
            , d "M121.004,131.87c0,32.104-26.024,58.13-58.13,58.13c-32.1,0-58.123-26.026-58.123-58.13 c0-48.907,58.123-128.797,58.123-128.797S121.004,82.451,121.004,131.87z"
            ]
            []
        , Svg.path
            [ fill (Color.toString options.center)
            , d "M105.585,128.817c0,23.587-19.124,42.707-42.708,42.707c-23.583,0-42.708-19.12-42.708-42.707 c0-23.584,19.125-42.708,42.708-42.708C86.461,86.109,105.585,105.233,105.585,128.817z"
            ]
            []
        ]
