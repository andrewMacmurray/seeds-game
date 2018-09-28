module Helpers.Css.Style exposing
    ( Style
    , addStyles
    , background
    , backgroundColor
    , backgroundImage
    , batchStyles
    , bottomStyle
    , classes
    , color
    , displayStyle
    , emptyStyle
    , frameBackgroundImage
    , heightStyle
    , leftPill
    , leftStyle
    , marginBottom
    , marginLeft
    , marginRight
    , marginTop
    , maxWidth
    , opacityStyle
    , paddingAll
    , paddingBottom
    , paddingLeft
    , paddingRight
    , paddingTop
    , rightPill
    , styleAttr
    , styles
    , svgStyle
    , svgStyles
    , topStyle
    , widthHeight
    , widthStyle
    )

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


addStyles : List Style -> List (Attribute msg) -> List (Attribute msg)
addStyles styleList attrs =
    attrs ++ styles styleList


batchStyles : List (List Style) -> List (Attribute msg) -> List (Attribute msg)
batchStyles styleList attrs =
    attrs ++ (styles <| List.concat styleList)


styles : List Style -> List (Attribute msg)
styles =
    List.map styleAttr


styleAttr : Style -> Attribute msg
styleAttr ( a, b ) =
    style a b


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


paddingTop : number -> Style
paddingTop n =
    ( "padding-top", px n )


paddingBottom : number -> Style
paddingBottom n =
    ( "padding-bottom", px n )


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
    \b -> ( "color", b )


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
    \b -> ( "background-color", b )


background : String -> Style
background =
    \b -> ( "background", b )


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
    \b -> ( "display", b )


opacityStyle : number -> Style
opacityStyle number =
    ( "opacity", Debug.toString number )
