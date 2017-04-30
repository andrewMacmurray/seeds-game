module Helpers.Style exposing (..)


px : number -> String
px n =
    (toString n) ++ "px"


classes : List String -> String
classes =
    String.join " "
