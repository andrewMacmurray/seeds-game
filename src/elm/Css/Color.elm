module Css.Color exposing
    ( Color
    , black
    , darkYellow
    , gold
    , lightGold
    , lightYellow
    , rainBlue
    , seedPodGradient
    , transparent
    , white
    )

import Utils.Unit as Unit


type alias Color =
    String



-- Gradients


seedPodGradient : Color
seedPodGradient =
    linearGradient seedPodGradient_


seedPodGradient_ : String
seedPodGradient_ =
    String.join ", "
        [ Unit.deg 90
        , lightGreen
        , gradientStop lightGreen 50
        , gradientStop green 50
        , green
        ]


gradientStop : String -> Float -> String
gradientStop stopColor percent =
    String.join " " [ stopColor, Unit.pc percent ]


linearGradient : String -> String
linearGradient x =
    String.concat [ "linear-gradient(", x, ")" ]


rgba : Int -> Int -> Int -> Float -> Color
rgba r g b a =
    "rgba("
        ++ String.join ","
            [ String.fromInt r
            , String.fromInt g
            , String.fromInt b
            , String.fromFloat a
            ]
        ++ ")"


rgb : Int -> Int -> Int -> Color
rgb r g b =
    "rgb("
        ++ String.join ","
            [ String.fromInt r
            , String.fromInt g
            , String.fromInt b
            ]
        ++ ")"



-- Colors


gold : Color
gold =
    rgb 255 160 0


lightGold : Color
lightGold =
    rgb 255 199 19


darkYellow : Color
darkYellow =
    rgb 201 153 6


lightYellow : Color
lightYellow =
    rgb 255 251 179


green : Color
green =
    rgb 113 175 68


lightGreen : Color
lightGreen =
    rgb 119 193 66


rainBlue : Color
rainBlue =
    rgb 97 188 255


transparent : Color
transparent =
    rgba 0 0 0 0


white : Color
white =
    rgb 255 255 255


black : Color
black =
    rgb 0 0 0
