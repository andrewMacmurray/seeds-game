module Data.Hub.Transition exposing (..)

import Data.Hub.Types exposing (..)
import Model exposing (..)
import Random exposing (..)


genRandomBackground : Cmd Msg
genRandomBackground =
    Random.int 1 10
        |> Random.map backgroundEnum
        |> Random.generate RandomBackground


backgroundEnum : Int -> TransitionBackground
backgroundEnum n =
    if n > 5 then
        Orange
    else
        Blue
