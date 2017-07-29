module Data.Color exposing (..)


seedPodGradient : String
seedPodGradient =
    "linear-gradient(" ++ seedPodGradient_ ++ ")"


seedPodGradient_ : String
seedPodGradient_ =
    String.join ", "
        [ "90deg"
        , lightGreen
        , lightGreen ++ " 50%"
        , green ++ " 51%"
        , green
        ]


darkRed : String
darkRed =
    "rgb(191, 30, 45)"


crimson : String
crimson =
    "rgb(237, 31, 36)"


orange : String
orange =
    "rgb(241, 101, 34)"


gold : String
gold =
    "rgb(255, 160, 0)"


darkYellow : String
darkYellow =
    "rgb(201, 153, 6)"


yellow : String
yellow =
    "rgb(255, 234, 124)"


blockYellow : String
blockYellow =
    "rgb(246, 224, 111)"


lightYellow : String
lightYellow =
    "rgb(255, 220, 115)"


washedYellow : String
washedYellow =
    "rgb(255, 254, 224)"


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


green : String
green =
    "rgb(113, 175, 68)"


lightGreen : String
lightGreen =
    "rgb(119, 193, 66)"


lightBlue : String
lightBlue =
    "rgb(38, 170, 224)"


purple : String
purple =
    "rgb(173, 81, 126)"
