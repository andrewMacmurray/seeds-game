module Css.Color exposing
    ( Color
    , black
    , blueGrey
    , brown
    , chocolate
    , crimson
    , darkRed
    , darkYellow
    , gold
    , lightBrown
    , lightGold
    , lightGray
    , lightYellow
    , midnightBlue
    , orange
    , pinkRed
    , purple
    , rainBlue
    , seedPodGradient
    , silver
    , transparent
    , transparentGray
    , white
    )

import Css.Unit exposing (deg, pc)


type alias Color =
    String



-- Gradients


seedPodGradient : Color
seedPodGradient =
    linearGradient seedPodGradient_


seedPodGradient_ : String
seedPodGradient_ =
    String.join ", "
        [ deg 90
        , lightGreen
        , gradientStop lightGreen 50
        , gradientStop green 50
        , green
        ]


gradientStop : String -> Float -> String
gradientStop stopColor percent =
    String.join " " [ stopColor, pc percent ]


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


darkRed : Color
darkRed =
    rgb 191 30 45


crimson : Color
crimson =
    rgb 237 31 36


pinkRed : Color
pinkRed =
    rgb 255 116 116


orange : Color
orange =
    rgb 241 101 34


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


lightBrown : Color
lightBrown =
    rgb 167 123 82


brown : Color
brown =
    rgb 119 76 40


chocolate : Color
chocolate =
    rgb 57 35 21


green : Color
green =
    rgb 113 175 68


lightGreen : Color
lightGreen =
    rgb 119 193 66


rainBlue : Color
rainBlue =
    rgb 97 188 255


blueGrey : Color
blueGrey =
    rgb 192 198 216


midnightBlue : Color
midnightBlue =
    rgb 6 24 35


purple : Color
purple =
    rgb 167 29 96


silver : Color
silver =
    rgb 226 226 226


lightGray : Color
lightGray =
    rgb 180 180 180


transparent : Color
transparent =
    rgba 0 0 0 0


transparentGray : Color
transparentGray =
    rgba 149 149 149 0.2


white : Color
white =
    rgb 255 255 255


black : Color
black =
    rgb 0 0 0
