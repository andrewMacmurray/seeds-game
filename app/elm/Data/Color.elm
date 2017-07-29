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


gold : String
gold =
    "rgb(255, 160, 0)"


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


brown : String
brown =
    "rgb(167, 123, 82)"


darkBrown : String
darkBrown =
    "rgb(97, 62, 16)"


green : String
green =
    "rgb(113, 175, 68)"


lightGreen : String
lightGreen =
    "rgb(119, 193, 66)"


lightBlue : String
lightBlue =
    "rgb(38, 170, 224)"
