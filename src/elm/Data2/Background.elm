module Data2.Background exposing (..)

import Random


type TransitionBackground
    = Orange
    | Blue


genRandomBackground : (TransitionBackground -> msg) -> Cmd msg
genRandomBackground msg =
    Random.int 1 10
        |> Random.map backgroundEnum
        |> Random.generate msg


backgroundEnum : Int -> TransitionBackground
backgroundEnum n =
    if n > 5 then
        Orange
    else
        Blue
