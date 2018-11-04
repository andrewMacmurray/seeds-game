module Config.Scale exposing
    ( ScreenSize(..)
    , baseTileSizeX
    , baseTileSizeY
    , scoreIconSize
    , screenSize
    , tileScaleFactor
    , topBarHeight
    , windowPadding
    )

import Shared exposing (Window)


type ScreenSize
    = Small
    | Medium
    | Large


tileScaleFactor : Window -> Float
tileScaleFactor window =
    case screenSize window of
        Small ->
            0.8

        Medium ->
            0.98

        Large ->
            1.2


screenSize : Window -> ScreenSize
screenSize window =
    let
        dimension =
            smallestWindowDimension window
    in
    if dimension < 480 then
        Small

    else if dimension > 480 && dimension < 720 then
        Medium

    else
        Large


smallestWindowDimension : Window -> Int
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
