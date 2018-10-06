module Css.Style exposing
    ( Style
    , background
    , backgroundColor
    , backgroundImage
    , borderNone
    , bottom
    , classes
    , color
    , compose
    , displayStyle
    , empty
    , height
    , left
    , leftAuto
    , leftPill
    , marginAuto
    , marginBottom
    , marginLeft
    , marginRight
    , marginTop
    , maxWidth
    , opacity
    , paddingAll
    , paddingBottom
    , paddingHorizontal
    , paddingLeft
    , paddingRight
    , paddingTop
    , paddingVertical
    , property
    , rightAuto
    , rightPill
    , stroke
    , style
    , styles
    , svgStyle
    , svgStyles
    , top
    , transform
    , transformOrigin
    , width
    , widthHeight
    )

import Css.Transform as Transform exposing (Transform)
import Css.Unit exposing (..)
import Html exposing (Attribute, Html)
import Html.Attributes
import Svg
import Svg.Attributes


type Style
    = Property String String
    | Raw String


property : String -> String -> Style
property =
    Property


compose : List Style -> Style
compose =
    Raw << renderStyles_


classes : List String -> Html.Attribute msg
classes =
    Html.Attributes.class << String.join " "



-- Html


styles : List (List Style) -> Html.Attribute msg
styles =
    Html.Attributes.attribute "style" << renderStyles_ << List.concat


style : List Style -> Html.Attribute msg
style =
    Html.Attributes.attribute "style" << renderStyles_



-- Svg


svgStyles : List Style -> Svg.Attribute msg
svgStyles =
    Svg.Attributes.style << renderStyles_


svgStyle : Style -> Svg.Attribute msg
svgStyle =
    Svg.Attributes.style << styleToString_



-- Render Styles to String


renderStyles_ : List Style -> String
renderStyles_ =
    List.map styleToString_ >> String.join ";"


styleToString_ : Style -> String
styleToString_ s =
    case s of
        Property prop val ->
            prop ++ ":" ++ val

        Raw val ->
            val



-- Properties


empty : Style
empty =
    property "" ""


transform : List Transform -> Style
transform transforms =
    property "transform" <| Transform.render transforms


transformOrigin : String -> Style
transformOrigin =
    property "transform-origin"


paddingAll : Float -> Style
paddingAll n =
    property "padding" <| px n


paddingHorizontal : Float -> Style
paddingHorizontal n =
    compose
        [ paddingLeft n
        , paddingRight n
        ]


paddingVertical : Float -> Style
paddingVertical n =
    compose
        [ paddingTop n
        , paddingBottom n
        ]


paddingLeft : Float -> Style
paddingLeft n =
    property "padding-left" <| px n


paddingRight : Float -> Style
paddingRight n =
    property "padding-right" <| px n


paddingTop : Float -> Style
paddingTop n =
    property "padding-top" <| px n


paddingBottom : Float -> Style
paddingBottom n =
    property "padding-bottom" <| px n


marginRight : Float -> Style
marginRight n =
    property "margin-right" <| px n


marginTop : Float -> Style
marginTop n =
    property "margin-top" <| px n


marginLeft : Float -> Style
marginLeft n =
    property "margin-left" <| px n


marginBottom : Float -> Style
marginBottom n =
    property "margin-bottom" <| px n


marginAuto : Style
marginAuto =
    property "margin" "auto"


leftAuto : Style
leftAuto =
    property "margin-left" "auto"


rightAuto : Style
rightAuto =
    property "margin-right" "auto"


top : Float -> Style
top n =
    property "top" <| px n


bottom : Float -> Style
bottom n =
    property "bottom" <| px n


left : Float -> Style
left n =
    property "left" <| px n


color : String -> Style
color c =
    property "color" c


borderNone : Style
borderNone =
    property "border" "none"


rightPill : Style
rightPill =
    compose
        [ property "border-top-right-radius" <| px 9999
        , property "border-bottom-right-radius" <| px 9999
        ]


leftPill : Style
leftPill =
    compose
        [ property "border-top-left-radius" <| px 9999
        , property "border-bottom-left-radius" <| px 9999
        ]


backgroundImage : String -> Style
backgroundImage url =
    property "background-image" <| "url(" ++ url ++ ")"


backgroundColor : String -> Style
backgroundColor =
    property "background-color"


background : String -> Style
background =
    property "background"


widthHeight : Float -> List Style
widthHeight n =
    [ width n
    , height n
    ]


width : Float -> Style
width n =
    property "width" <| px n


maxWidth : Float -> Style
maxWidth n =
    property "max-width" <| px n


height : Float -> Style
height h =
    property "height" <| px h


displayStyle : String -> Style
displayStyle d =
    property "display" <| d


opacity : Float -> Style
opacity o =
    property "opacity" <| String.fromFloat o


stroke : String -> Style
stroke =
    property "stroke"
