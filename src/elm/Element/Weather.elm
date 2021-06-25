module Element.Weather exposing
    ( bright
    , dark
    , medium
    , rain
    , small
    , sun
    )

import Element exposing (..)
import Element.Dot as Dot
import Element.Palette as Palette
import Element.Scale as Scale



-- Sun


type alias SunOptions =
    { size : Int
    , shade : Shade
    }


sun : SunOptions -> Element msg
sun options =
    weather (sunColor options) options.size


sunColor : SunOptions -> Color
sunColor options =
    case options.shade of
        Bright ->
            Palette.gold

        Dark ->
            Palette.orange



-- Rain


rain : Int -> Element msg
rain =
    weather Palette.blue5



-- Options


type Shade
    = Bright
    | Dark


bright : Shade
bright =
    Bright


dark : Shade
dark =
    Dark


medium : number
medium =
    25


small : number
small =
    8



-- Internal


weather : Color -> Int -> Element msg
weather color size =
    el [ paddingXY 0 Scale.extraSmall ]
        (Dot.solid
            { size = size
            , color = color
            }
        )
