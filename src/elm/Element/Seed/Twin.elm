module Element.Seed.Twin exposing (seed)

import Element exposing (Color)
import Element.Icon as Icon
import Svg
import Svg.Attributes exposing (..)
import Utils.Color as Color
import Utils.Svg as Svg



-- Twin Seed


type alias Options =
    { left : Color
    , right : Color
    }


seed : Options -> Icon.Dual msg
seed options =
    Icon.dual
        [ Svg.viewBox_ 0 0 124 193
        , Svg.fullWidth
        ]
        [ Svg.path
            [ fill (Color.toString options.left)
            , d "M62.33,3.285c0,0-58.047,79.778-58.047,128.616c0,32.059,25.988,58.049,58.047,58.049 c0.057,0,0.113-0.004,0.17-0.004V3.519C62.388,3.365,62.33,3.285,62.33,3.285z"
            ]
            []
        , Svg.path
            [ fill (Color.toString options.right)
            , d "M120.376,131.901c0-47.796-54.445-123.649-57.876-128.383v186.428 C94.479,189.854,120.376,163.903,120.376,131.901z"
            ]
            []
        ]
