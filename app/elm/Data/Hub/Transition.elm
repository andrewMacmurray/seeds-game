module Data.Hub.Transition exposing (..)

import Data.Hub.Types exposing (..)
import Random exposing (..)


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
