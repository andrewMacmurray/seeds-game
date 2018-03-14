module Helpers.Style exposing (..)

import Formatting exposing (..)
import Html exposing (Attribute)
import Html.Attributes exposing (class, style)
import Svg.Attributes
import Svg


type alias Style =
    ( String, String )


classes : List String -> Attribute msg
classes =
    class << String.join " "


styles : List (List Style) -> Attribute msg
styles =
    style << List.concat


svgStyles : List String -> Svg.Attribute msg
svgStyles =
    Svg.Attributes.style << String.join "; "


svgStyle : String -> String -> Svg.Attribute msg
svgStyle a b =
    Svg.Attributes.style <| a ++ ":" ++ b


emptyStyle : Style
emptyStyle =
    ( "", "" )


paddingAll : number -> Style
paddingAll n =
    ( "padding", px n )


marginRight : number -> Style
marginRight n =
    ( "margin-right", px n )


marginTop : number -> Style
marginTop n =
    ( "margin-top", px n )


marginLeft : number -> Style
marginLeft n =
    ( "margin-left", px n )


marginBottom : number -> Style
marginBottom n =
    ( "margin-bottom", px n )


topStyle : number -> Style
topStyle n =
    ( "top", px n )


bottomStyle : number -> Style
bottomStyle n =
    ( "bottom", px n )


leftStyle : number -> Style
leftStyle n =
    ( "left", px n )


color : String -> Style
color =
    (,) "color"


rightPill : List Style
rightPill =
    [ ( "border-top-right-radius", px 9999 )
    , ( "border-bottom-right-radius", px 9999 )
    ]


leftPill : List Style
leftPill =
    [ ( "border-top-left-radius", px 9999 )
    , ( "border-bottom-left-radius", px 9999 )
    ]


frameBackgroundImage : List Style
frameBackgroundImage =
    [ ( "background-position", "center" )
    , ( "background-repeat", "no-repeat" )
    , ( "background-size", "contain" )
    ]


backgroundImage : String -> Style
backgroundImage url =
    ( "background-image", "url(" ++ url ++ ")" )


backgroundColor : String -> Style
backgroundColor =
    (,) "background-color"


background : String -> Style
background =
    (,) "background"


widthHeight : number -> List Style
widthHeight n =
    [ widthStyle n
    , heightStyle n
    ]


widthStyle : number -> Style
widthStyle width =
    ( "width", px width )


maxWidth : number -> Style
maxWidth width =
    ( "max-width", px width )


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


animationDelayStyle : number -> Style
animationDelayStyle delay =
    ( "animation-delay", ms delay )


fillForwards : Style
fillForwards =
    fillModeStyle "forwards"


fillModeStyle : String -> Style
fillModeStyle =
    (,) "animation-fill-mode"


opacityStyle : number -> Style
opacityStyle number =
    ( "opacity", toString number )


pc : number -> String
pc =
    print pc_


pc_ : Format r (number -> r)
pc_ =
    number <> s "%"


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


gradientStop : String -> number -> String
gradientStop =
    print gradientStop_


gradientStop_ : Format r (String -> number -> r)
gradientStop_ =
    string <> s " " <> pc_


linearGradient : String -> String
linearGradient =
    print linearGradient_


linearGradient_ : Format r (String -> r)
linearGradient_ =
    s "linear-gradient(" <> string <> s ")"


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


svgTranslate : number -> number -> String
svgTranslate =
    print svgTranslate_


svgTranslate_ : Format r (number -> number -> r)
svgTranslate_ =
    s "translate(" <> number <> s " " <> number <> s ")"


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
