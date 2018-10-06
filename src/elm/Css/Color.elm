module Css.Color exposing
    ( Color
    , blockYellow
    , brown
    , brownYellow
    , chocolate
    , crimson
    , darkBrown
    , darkRed
    , darkYellow
    , fadedOrange
    , gold
    , green
    , greyYellow
    , lightBlue
    , lightBrown
    , lightGold
    , lightGray
    , lightGreen
    , lightOrange
    , lightYellow
    , meadowGreen
    , mediumGreen
    , midnightBlue
    , orange
    , pinkRed
    , purple
    , rainBlue
    , seedPodGradient
    , silver
    , skyGreen
    , skyYellow
    , softRed
    , transparent
    , transparentGray
    , washedYellow
    , white
    , yellow
    )

import Css.Unit exposing (deg, pc)


type alias Color =
    String


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


darkRed : Color
darkRed =
    "rgb(191, 30, 45)"


crimson : Color
crimson =
    "rgb(237, 31, 36)"


softRed : Color
softRed =
    "rgb(235, 76, 72)"


pinkRed : Color
pinkRed =
    "rgb(255, 116, 116)"


fadedOrange : Color
fadedOrange =
    "rgb(247, 179, 113)"


lightOrange : Color
lightOrange =
    "rgb(238, 124, 51)"


orange : Color
orange =
    "rgb(241, 101, 34)"


gold : Color
gold =
    "rgb(255, 160, 0)"


lightGold : Color
lightGold =
    "rgb(255, 199, 19)"


darkYellow : Color
darkYellow =
    "rgb(201, 153, 6)"


brownYellow : Color
brownYellow =
    "rgb(105, 88, 35)"


yellow : Color
yellow =
    "rgb(255, 234, 124)"


skyYellow : Color
skyYellow =
    "rgb(255, 227, 137)"


blockYellow : Color
blockYellow =
    "rgb(246, 224, 111)"


lightYellow : Color
lightYellow =
    "rgb(255, 251, 179)"


washedYellow : Color
washedYellow =
    "rgb(255, 254, 224)"


greyYellow : Color
greyYellow =
    "rgba(195, 167, 82, 0.65)"


lightBrown : Color
lightBrown =
    "rgb(167, 123, 82)"


brown : Color
brown =
    "rgb(119, 76, 40)"


darkBrown : Color
darkBrown =
    "rgb(97, 62, 16)"


chocolate : Color
chocolate =
    "rgb(57, 35, 21)"


mediumGreen : Color
mediumGreen =
    "rgb(78, 168, 59)"


green : Color
green =
    "rgb(113, 175, 68)"


lightGreen : Color
lightGreen =
    "rgb(119, 193, 66)"


skyGreen : Color
skyGreen =
    "rgb(166, 255, 150)"


meadowGreen : Color
meadowGreen =
    "rgb(91, 201, 120)"


lightBlue : Color
lightBlue =
    "rgb(38, 170, 224)"


rainBlue : Color
rainBlue =
    "rgb(97, 188, 255)"


midnightBlue : Color
midnightBlue =
    "rgb(6, 24, 35)"


purple : Color
purple =
    "rgb(173, 81, 126)"


silver : Color
silver =
    "rgb(226, 226, 226)"


lightGray : Color
lightGray =
    "rgb(180, 180, 180)"


transparent : Color
transparent =
    "rgba(0, 0, 0, 0)"


transparentGray : Color
transparentGray =
    "rgba(149, 149, 149, 0.2)"


white : Color
white =
    "rgb(255, 255, 255)"
