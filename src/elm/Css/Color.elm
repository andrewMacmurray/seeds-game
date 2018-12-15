module Css.Color exposing
    ( Color
    , ashGreen
    , black
    , blockYellow
    , brown
    , brownYellow
    , chocolate
    , crimson
    , darkBlue
    , darkBrown
    , darkForestGreen
    , darkRed
    , darkSeaGreen
    , darkYellow
    , deepPine
    , fadedOrange
    , firrGreen
    , gold
    , green
    , greyYellow
    , lightBlue
    , lightBrown
    , lightGold
    , lightGray
    , lightGreen
    , lightGreyYellow
    , lightOrange
    , lightPine
    , lightYellow
    , meadowGreen
    , mediumGreen
    , midnightBlue
    , orange
    , petalOrange
    , pineGreen
    , pinkRed
    , purple
    , rainBlue
    , rgb
    , rgba
    , seaGreen
    , seedPodGradient
    , silver
    , skyGreen
    , softRed
    , sunflowerOffYellow
    , sunflowerYellow
    , transparent
    , transparentGray
    , washedYellow
    , white
    , yellow
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
    String.join "" [ "linear-gradient(", x, ")" ]


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


softRed : Color
softRed =
    rgb 235 76 72


pinkRed : Color
pinkRed =
    rgb 255 116 116


fadedOrange : Color
fadedOrange =
    rgb 247 179 113


petalOrange : Color
petalOrange =
    rgb 255 204 71


lightOrange : Color
lightOrange =
    rgb 238 124 51


orange : Color
orange =
    rgb 241 101 34


gold : Color
gold =
    rgb 255 160 0


lightGold : Color
lightGold =
    rgb 255 199 19


lightGreyYellow : Color
lightGreyYellow =
    rgb 255 223 119


darkYellow : Color
darkYellow =
    rgb 201 153 6


brownYellow : Color
brownYellow =
    rgb 105 88 35


sunflowerYellow : Color
sunflowerYellow =
    rgb 255 241 0


sunflowerOffYellow : Color
sunflowerOffYellow =
    rgb 226 227 24


yellow : Color
yellow =
    rgb 255 234 124


blockYellow : Color
blockYellow =
    rgb 246 224 111


lightYellow : Color
lightYellow =
    rgb 255 251 179


washedYellow : Color
washedYellow =
    rgb 255 254 224


greyYellow : Color
greyYellow =
    rgba 195 167 82 0.65


lightBrown : Color
lightBrown =
    rgb 167 123 82


brown : Color
brown =
    rgb 119 76 40


darkBrown : Color
darkBrown =
    rgb 97 62 16


chocolate : Color
chocolate =
    rgb 57 35 21


mediumGreen : Color
mediumGreen =
    rgb 78 168 59


green : Color
green =
    rgb 113 175 68


lightGreen : Color
lightGreen =
    rgb 119 193 66


skyGreen : Color
skyGreen =
    rgb 164 255 186


meadowGreen : Color
meadowGreen =
    rgb 91 201 120


lightPine : Color
lightPine =
    rgb 86 180 102


firrGreen : Color
firrGreen =
    rgb 93 136 61


pineGreen : Color
pineGreen =
    rgb 64 145 78


deepPine : Color
deepPine =
    rgb 38 129 53


seaGreen : Color
seaGreen =
    rgb 31 125 92


darkSeaGreen : Color
darkSeaGreen =
    rgb 21 103 77


darkForestGreen : Color
darkForestGreen =
    rgb 8 71 38


ashGreen : Color
ashGreen =
    rgb 58 94 82


lightBlue : Color
lightBlue =
    rgb 38 170 224


rainBlue : Color
rainBlue =
    rgb 97 188 255


darkBlue : Color
darkBlue =
    rgb 7 28 65


midnightBlue : Color
midnightBlue =
    rgb 6 24 35


purple : Color
purple =
    rgb 173 81 126


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
