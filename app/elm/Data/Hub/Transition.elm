module Data.Hub.Transition exposing (..)

import Scenes.Hub.Types exposing (..)
import Scenes.Hub.Types exposing (..)
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
