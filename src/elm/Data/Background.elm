module Data.Background exposing
    ( Background(..)
    , genRandomBackground
    )

import Random


type Background
    = Orange
    | Blue


genRandomBackground : (Background -> msg) -> Cmd msg
genRandomBackground msg =
    Random.int 1 10
        |> Random.map backgroundEnum
        |> Random.generate msg


backgroundEnum : Int -> Background
backgroundEnum n =
    if n > 5 then
        Orange

    else
        Blue
