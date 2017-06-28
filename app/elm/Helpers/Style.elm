module Helpers.Style exposing (..)

import Formatting exposing (..)


classes : List String -> String
classes =
    String.join " "


styles : List (List ( String, String )) -> List ( String, String )
styles =
    List.concat


emptyStyle : ( String, String )
emptyStyle =
    ( "", "" )


px : number -> String
px =
    print px_


px_ : Format r (number -> r)
px_ =
    number <> s "px"


ms : number -> String
ms =
    print ms_


ms_ : Format r (number -> r)
ms_ =
    number <> s "ms"


opacity : number -> String
opacity =
    print opacity_


opacity_ : Format r (number -> r)
opacity_ =
    s "opacity: " <> number <> s ";"


transform_ : Format r a -> Format r a
transform_ formatter =
    s "transform: " <> formatter <> s ";"


translateY : number -> String
translateY =
    print translateY_


translateY_ : Format r (number -> r)
translateY_ =
    s "translateY(" <> px_ <> s ")"


translate : number -> number -> String
translate =
    print translate_


translate_ : Format r (number -> number -> r)
translate_ =
    s "translate(" <> px_ <> s ", " <> px_ <> s ")"


scale : number -> String
scale =
    print scale_


scale_ : Format r (number -> r)
scale_ =
    s "scale(" <> number <> s ")"


translateScale : number1 -> number2 -> number3 -> String
translateScale =
    print <| translate_ <> scale_


keyframesAnimation : String -> List String -> String
keyframesAnimation =
    print keyframesAnimation_


keyframesAnimation_ : Format r (String -> List String -> r)
keyframesAnimation_ =
    s "@keyframes " <> string <> s " { " <> joinStrings_ <> s " }"


joinStrings_ : Format r (List String -> r)
joinStrings_ =
    premap (String.join " ") string


step : Format String a -> Int -> a
step formatter =
    formatter
        |> step_
        |> print


step_ : Format r a -> Format r (Int -> a)
step_ formatter =
    int <> s "% { " <> formatter <> s "; }"
