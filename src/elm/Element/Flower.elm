module Element.Flower exposing
    ( Colors
    , background
    , textColor
    )

import Element exposing (Color)
import Element.Palette as Palette
import Seed exposing (Seed)



-- Flower Colors


type alias Colors =
    { background : Color
    , text : Color
    }


textColor : Seed -> Color
textColor =
    colors >> .text


background : Seed -> Color
background =
    colors >> .background


colors : Seed -> Colors
colors seed =
    case seed of
        Seed.Sunflower ->
            { background = Palette.green10
            , text = Palette.white
            }

        Seed.Chrysanthemum ->
            { background = Palette.purple10
            , text = Palette.purple10
            }

        Seed.Cornflower ->
            { background = Palette.yellow10
            , text = Palette.brown1
            }

        _ ->
            { background = Palette.green10
            , text = Palette.green1
            }
