module Data.Level.Scale exposing (..)

import Window exposing (Size)


tileScaleFactor : Size -> Float
tileScaleFactor window =
    let
        dimension =
            smallest window
    in
        if dimension < 480 then
            0.8
        else if dimension > 480 && dimension < 720 then
            1
        else
            1.2


smallest : Size -> Int
smallest { height, width } =
    if height >= width then
        width
    else
        height
