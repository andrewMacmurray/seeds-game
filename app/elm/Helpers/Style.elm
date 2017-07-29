module Helpers.Style exposing (..)

import Formatting exposing (..)
import Model exposing (Style)


classes : List String -> String
classes =
    String.join " "


styles : List (List Style) -> List Style
styles =
    List.concat


svgStyles : List String -> String
svgStyles =
    String.join "; "


emptyStyle : Style
emptyStyle =
    ( "", "" )


backgroundImage : String -> Style
backgroundImage url =
    ( "background-image", "url(" ++ url ++ ")" )


size : number -> List Style
size n =
    [ widthStyle n
    , heightStyle n
    ]


widthStyle : number -> Style
widthStyle width =
    ( "width", px width )


heightStyle : number -> Style
heightStyle height =
    ( "height", px height )


displayStyle : String -> Style
displayStyle =
    (,) "display"


transformStyle : String -> Style
transformStyle =
    (,) "transform"


transitionStyle : String -> Style
transitionStyle =
    (,) "transition"


transitionDelayStyle : number -> Style
transitionDelayStyle delay =
    ( "transition-delay", ms delay )


animationStyle : String -> Style
animationStyle =
    (,) "animation"


animationDelayStyle : String -> Style
animationDelayStyle =
    (,) "animation-delay"


fillModeStyle : String -> Style
fillModeStyle =
    (,) "animation-fill-mode"


opacityStyle : number -> Style
opacityStyle number =
    ( "opacity", toString number )


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


deg : number -> String
deg =
    print deg_


deg_ : Format r (number -> r)
deg_ =
    number <> s "deg"


opacity_ : Format r (number -> r)
opacity_ =
    s "opacity: " <> number <> s ";"


transform_ : Format r a -> Format r a
transform_ formatter =
    s "transform: " <> formatter <> s ";"


rotateZ_ : Format r (number -> r)
rotateZ_ =
    s "rotateZ(" <> deg_ <> s ")"


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
