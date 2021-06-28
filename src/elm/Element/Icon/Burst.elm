module Element.Icon.Burst exposing
    ( active_
    , inactive_
    )

import Element exposing (Color)
import Element.Palette as Palette
import Svg exposing (Svg)
import Svg.Attributes exposing (..)
import Utils.Color as Color
import Utils.Svg as Svg



-- Burst


type alias Options =
    { color : Color
    , border : Color
    }



-- Inactive


inactive_ : Svg msg
inactive_ =
    active_ inactiveOptions


inactiveOptions : Options
inactiveOptions =
    { color = Palette.slateGrey
    , border = Palette.background1_
    }



-- Active


active_ : Options -> Svg msg
active_ options =
    Svg.svg
        [ Svg.viewBox_ 0 0 11 11
        , Svg.fullWidth
        , fillRule "evenodd"
        , clipRule "evenodd"
        , strokeLinejoin "round"
        ]
        [ Svg.path
            [ d "M10.004 5.252L5.252.5.5 5.252l4.752 4.752 4.752-4.752z"
            , fill (Color.toString options.border)
            ]
            []
        , Svg.path
            [ d "M10.357 5.605a.5003.5003 0 000-.707L5.605.146a.5003.5003 0 00-.707 0L.146 4.898a.5003.5003 0 000 .707l4.752 4.752c.195.195.512.195.707 0l4.752-4.752zm-1.061-.353L5.252 9.296 1.207 5.252l4.045-4.045 4.044 4.045z"
            , fill (Color.toString options.color)
            ]
            []
        ]
