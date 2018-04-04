module Helpers.Css.Style exposing (..)

import Formatting exposing (..)
import Helpers.Css.Format exposing (..)
import Html exposing (Attribute)
import Html.Attributes exposing (class, style)
import Svg
import Svg.Attributes


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


paddingLeft : number -> Style
paddingLeft n =
    ( "padding-left", px n )


paddingRight : number -> Style
paddingRight n =
    ( "padding-right", px n )


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


opacityStyle : number -> Style
opacityStyle number =
    ( "opacity", toString number )


pc : number -> String
pc =
    print pc_


px : number -> String
px =
    print px_


ms : number -> String
ms =
    print ms_


deg : number -> String
deg =
    print deg_


gradientStop : String -> number -> String
gradientStop =
    print gradientStop_


linearGradient : String -> String
linearGradient =
    print linearGradient_


svgTranslate : number -> number -> String
svgTranslate =
    print svgTranslate_
