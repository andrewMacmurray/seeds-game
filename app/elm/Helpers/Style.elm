module Helpers.Style exposing (..)


px : number -> String
px n =
    (toString n) ++ "px"


translate : number -> number -> String
translate =
    translateWithUnit px


translateWithUnit : (number -> String) -> number -> number -> String
translateWithUnit unit x y =
    String.concat
        [ "translate(", unit x, ", ", unit y, ")" ]


classes : List String -> String
classes =
    String.join " "


styles : List (List ( String, String )) -> List ( String, String )
styles =
    List.concat
