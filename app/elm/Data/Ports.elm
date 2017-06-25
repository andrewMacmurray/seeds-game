port module Data.Ports exposing (..)


addCssAnimations : List String -> Cmd msg
addCssAnimations animations =
    animations
        |> String.join " "
        |> addCssAnimations_


port addCssAnimations_ : String -> Cmd msg
