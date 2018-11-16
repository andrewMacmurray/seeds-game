module Config.Scale exposing
    ( baseTileSizeX
    , baseTileSizeY
    , scoreIconSize
    , tileScaleFactor
    , topBarHeight
    )

import Data.Window exposing (..)


tileScaleFactor : Window -> Float
tileScaleFactor window =
    case size window of
        Small ->
            0.8

        Medium ->
            0.98

        Large ->
            1.2


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
