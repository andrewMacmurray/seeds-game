module Element.Weather exposing (rain, sun)

import Element exposing (..)
import Element.Dot as Dot
import Element.Palette as Palette
import Element.Scale as Scale



-- Weather


sun : Element msg
sun =
    weather Palette.orange medium


rain : Element msg
rain =
    weather Palette.blue5 medium


medium : number
medium =
    25



-- Internal


weather : Color -> Int -> Element msg
weather color size =
    el [ paddingXY 0 Scale.extraSmall ]
        (Dot.solid
            { size = size
            , color = color
            }
        )
