module Css.Style exposing
    ( Style
    , applyIf
    , background
    , backgroundColor
    , border
    , borderNone
    , classes
    , color
    , compose
    , height
    , left
    , marginBottom
    , marginLeft
    , marginRight
    , marginTop
    , none
    , opacity
    , paddingAll
    , paddingHorizontal
    , paddingVertical
    , property
    , renderStyles_
    , showIf
    , style
    , svgStyle
    , top
    , transform
    , transformOrigin
    , width
    )

import Css.Color as Color
import Css.Transform as Transform exposing (Transform)
import Css.Unit exposing (..)
import Html
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



-- Html


style : List Style -> Html.Attribute msg
style =
    Html.Attributes.attribute "style" << renderStyles_



-- Svg


svgStyle : List Style -> Svg.Attribute msg
svgStyle =
    Svg.Attributes.style << renderStyles_



-- Render Styles to Raw String


renderStyles_ : List Style -> String
renderStyles_ =
    List.filter isNonEmpty
        >> List.map styleToString_
        >> String.join ";"


styleToString_ : Style -> String
styleToString_ s =
    case s of
        Property prop val ->
            prop ++ ":" ++ val

        Raw val ->
            val


isNonEmpty : Style -> Bool
isNonEmpty s =
    case s of
        Property prop val ->
            nonEmpty prop && nonEmpty val

        Raw _ ->
            True


nonEmpty : String -> Bool
nonEmpty =
    String.trim >> String.isEmpty >> not



-- Properties


none : Style
none =
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


top : Float -> Style
top n =
    property "top" <| px n


left : Float -> Style
left n =
    property "left" <| px n


color : String -> Style
color c =
    property "color" c


borderNone : Style
borderNone =
    property "border" "none"


border : Float -> Color.Color -> Style
border n c =
    property "border" <| String.join " " [ px n, "solid", c ]


backgroundColor : String -> Style
backgroundColor =
    property "background-color"


background : String -> Style
background =
    property "background"


width : Float -> Style
width n =
    property "width" <| px n


height : Float -> Style
height h =
    property "height" <| px h


opacity : Float -> Style
opacity o =
    property "opacity" <| String.fromFloat o


showIf : Bool -> Style
showIf predicate =
    if predicate then
        opacity 1

    else
        opacity 0


applyIf : Bool -> Style -> Style
applyIf predicate s =
    if predicate then
        s

    else
        none



-- Class Helpers


classes : List String -> Html.Attribute msg
classes =
    Html.Attributes.class << String.join " "
