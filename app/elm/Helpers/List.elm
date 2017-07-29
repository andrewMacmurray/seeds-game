module Helpers.List exposing (..)


allTrue : List Bool -> Bool
allTrue =
    List.foldr (&&) True


anyTrue : List Bool -> Bool
anyTrue =
    List.foldr (||) False
