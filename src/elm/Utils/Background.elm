module Utils.Background exposing (split)

import Element exposing (Attribute, Color)
import Utils.Color as Color
import Utils.Element as Element
import Utils.Unit as Unit


type alias Split =
    ( Color, Color )


split : Split -> Attribute msg
split =
    Element.style "background" << splitGradient


splitGradient : Split -> String
splitGradient split_ =
    String.concat
        [ "linear-gradient("
        , splitGradient_ split_
        , ")"
        ]


splitGradient_ : Split -> String
splitGradient_ ( left, right ) =
    String.join ", "
        [ Unit.deg 90
        , Color.toString left
        , gradientStop left 50
        , gradientStop right 50
        , Color.toString right
        ]


gradientStop : Color -> Float -> String
gradientStop stopColor percent =
    String.join " "
        [ Color.toString stopColor
        , Unit.pc percent
        ]
