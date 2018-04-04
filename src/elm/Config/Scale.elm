module Config.Scale exposing (..)

import Window


tileScaleFactor : Window.Size -> Float
tileScaleFactor window =
    let
        dimension =
            smallestWindowDimension window
    in
        if dimension < 480 then
            0.8
        else if dimension > 480 && dimension < 720 then
            0.98
        else
            1.2


smallestWindowDimension : Window.Size -> Int
smallestWindowDimension { height, width } =
    if height >= width then
        width
    else
        height


scoreIconSize : number
scoreIconSize =
    32


baseTileSizeX : number
baseTileSizeX =
    55


baseTileSizeY : number
baseTileSizeY =
    51


topBarHeight : number
topBarHeight =
    80


windowPadding : number
windowPadding =
    35
