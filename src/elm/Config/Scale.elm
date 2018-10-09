module Config.Scale exposing
    ( baseTileSizeX
    , baseTileSizeY
    , scoreIconSize
    , smallestWindowDimension
    , tileScaleFactor
    , topBarHeight
    , windowPadding
    )

import Data.Window as Window


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


scoreIconSize : Float
scoreIconSize =
    32


baseTileSizeX : Float
baseTileSizeX =
    55


baseTileSizeY : Float
baseTileSizeY =
    51


topBarHeight : Float
topBarHeight =
    80


windowPadding : Float
windowPadding =
    35
