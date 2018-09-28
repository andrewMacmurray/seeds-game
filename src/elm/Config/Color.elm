module Config.Color exposing
    ( blockYellow
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
    , seedPodGradient_
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

import Helpers.Css.Format exposing (deg, gradientStop, linearGradient, pc)


seedPodGradient : String
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


darkRed : String
darkRed =
    "rgb(191, 30, 45)"


crimson : String
crimson =
    "rgb(237, 31, 36)"


softRed : String
softRed =
    "rgb(235, 76, 72)"


pinkRed : String
pinkRed =
    "rgb(255, 116, 116)"


fadedOrange : String
fadedOrange =
    "rgb(247, 179, 113)"


lightOrange : String
lightOrange =
    "rgb(238, 124, 51)"


orange : String
orange =
    "rgb(241, 101, 34)"


gold : String
gold =
    "rgb(255, 160, 0)"


lightGold : String
lightGold =
    "rgb(255, 199, 19)"


darkYellow : String
darkYellow =
    "rgb(201, 153, 6)"


brownYellow : String
brownYellow =
    "rgb(105, 88, 35)"


yellow : String
yellow =
    "rgb(255, 234, 124)"


skyYellow : String
skyYellow =
    "rgb(255, 227, 137)"


blockYellow : String
blockYellow =
    "rgb(246, 224, 111)"


lightYellow : String
lightYellow =
    "rgb(255, 251, 179)"


washedYellow : String
washedYellow =
    "rgb(255, 254, 224)"


greyYellow : String
greyYellow =
    "rgba(195, 167, 82, 0.65)"


lightBrown : String
lightBrown =
    "rgb(167, 123, 82)"


brown : String
brown =
    "rgb(119, 76, 40)"


darkBrown : String
darkBrown =
    "rgb(97, 62, 16)"


chocolate : String
chocolate =
    "rgb(57, 35, 21)"


mediumGreen : String
mediumGreen =
    "rgb(78, 168, 59)"


green : String
green =
    "rgb(113, 175, 68)"


lightGreen : String
lightGreen =
    "rgb(119, 193, 66)"


skyGreen : String
skyGreen =
    "rgb(166, 255, 150)"


meadowGreen : String
meadowGreen =
    "rgb(91, 201, 120)"


lightBlue : String
lightBlue =
    "rgb(38, 170, 224)"


rainBlue : String
rainBlue =
    "rgb(97, 188, 255)"


midnightBlue : String
midnightBlue =
    "rgb(6, 24, 35)"


purple : String
purple =
    "rgb(173, 81, 126)"


silver : String
silver =
    "rgb(226, 226, 226)"


lightGray : String
lightGray =
    "rgb(180, 180, 180)"


transparent : String
transparent =
    "rgba(0, 0, 0, 0)"


transparentGray : String
transparentGray =
    "rgba(149, 149, 149, 0.2)"


white : String
white =
    "rgb(255, 255, 255)"
