module Helpers.Css.Format exposing (..)

import Formatting exposing (..)


-- Transforms


scale_ : Format r (number -> r)
scale_ =
    s "scale(" <> number <> s ")"


translate_ : Format r (number -> number -> r)
translate_ =
    s "translate(" <> px_ <> s ", " <> px_ <> s ")"


translateY_ : Format r (number -> r)
translateY_ =
    s "translateY(" <> px_ <> s ")"


rotate_ : String -> Format r (number -> r)
rotate_ dimension =
    s ("rotate" ++ dimension ++ "(") <> deg_ <> s ")"


svgTranslate_ : Format r (number -> number -> r)
svgTranslate_ =
    s "translate(" <> number <> s " " <> number <> s ")"


transformInline_ : Format r a -> Format r a
transformInline_ formatter =
    s "transform: " <> formatter <> s ";"



-- Animation


keyframesAnimation_ : Format r (String -> List String -> r)
keyframesAnimation_ =
    s "@keyframes " <> string <> s " { " <> joinStrings_ <> s " }"


joinStrings_ : Format r (List String -> r)
joinStrings_ =
    premap (String.join " ") string


step_ : Format r a -> Format r (Int -> a)
step_ formatter =
    int <> s "% { " <> formatter <> s "; }"



-- Units


pc_ : Format r (number -> r)
pc_ =
    number <> s "%"


px_ : Format r (number -> r)
px_ =
    number <> s "px"


ms_ : Format r (number -> r)
ms_ =
    number <> s "ms"


deg_ : Format r (number -> r)
deg_ =
    number <> s "deg"



-- Misc


gradientStop_ : Format r (String -> number -> r)
gradientStop_ =
    string <> s " " <> pc_


linearGradient_ : Format r (String -> r)
linearGradient_ =
    s "linear-gradient(" <> string <> s ")"


opacity_ : Format r (number -> r)
opacity_ =
    s "opacity: " <> number <> s ";"
