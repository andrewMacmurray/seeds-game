module Helpers.Css.Style exposing
    ( Style
    , background
    , backgroundColor
    , backgroundImage
    , borderNone
    , bottom
    , classes
    , color
    , displayStyle
    , empty
    , frameBackgroundImage
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

import Helpers.Css.Transform as Transform exposing (Transform)
import Helpers.Css.Unit exposing (..)
import Html exposing (Attribute, Html)
import Html.Attributes
import Svg
import Svg.Attributes


type Style
    = Style String String


property : String -> String -> Style
property =
    Style


classes : List String -> Attribute msg
classes =
    Html.Attributes.class << String.join " "



-- Html


styles : List (List Style) -> Attribute msg
styles =
    renderHtmlStyles << List.concat


style : List Style -> Attribute msg
style =
    renderHtmlStyles


renderHtmlStyles : List Style -> Attribute msg
renderHtmlStyles xs =
    let
        css =
            xs |> List.foldl (\(Style prop val) acc -> acc ++ (prop ++ ":" ++ val ++ ";")) ""
    in
    Html.Attributes.attribute "style" css



-- Svg


svgStyles : List Style -> Svg.Attribute msg
svgStyles =
    List.map renderSvgStyle
        >> String.join "; "
        >> Svg.Attributes.style


svgStyle : Style -> Svg.Attribute msg
svgStyle =
    Svg.Attributes.style << renderSvgStyle


renderSvgStyle : Style -> String
renderSvgStyle (Style prop val) =
    prop ++ ":" ++ val



-- Properties


empty : Style
empty =
    Style "" ""


transform : List Transform -> Style
transform transforms =
    Style "transform" <| Transform.render transforms


transformOrigin : String -> Style
transformOrigin =
    Style "transform-origin"


paddingAll : Float -> Style
paddingAll n =
    Style "padding" <| px n


paddingHorizontal : Float -> List Style
paddingHorizontal n =
    [ paddingLeft n
    , paddingRight n
    ]


paddingVertical : Float -> List Style
paddingVertical n =
    [ paddingTop n
    , paddingBottom n
    ]


paddingLeft : Float -> Style
paddingLeft n =
    Style "padding-left" <| px n


paddingRight : Float -> Style
paddingRight n =
    Style "padding-right" <| px n


paddingTop : Float -> Style
paddingTop n =
    Style "padding-top" <| px n


paddingBottom : Float -> Style
paddingBottom n =
    Style "padding-bottom" <| px n


marginRight : Float -> Style
marginRight n =
    Style "margin-right" <| px n


marginTop : Float -> Style
marginTop n =
    Style "margin-top" <| px n


marginLeft : Float -> Style
marginLeft n =
    Style "margin-left" <| px n


marginBottom : Float -> Style
marginBottom n =
    Style "margin-bottom" <| px n


marginAuto : Style
marginAuto =
    Style "margin" "auto"


leftAuto : Style
leftAuto =
    Style "margin-left" "auto"


rightAuto : Style
rightAuto =
    Style "margin-right" "auto"


top : Float -> Style
top n =
    Style "top" <| px n


bottom : Float -> Style
bottom n =
    Style "bottom" <| px n


left : Float -> Style
left n =
    Style "left" <| px n


color : String -> Style
color c =
    Style "color" c


borderNone : Style
borderNone =
    Style "border" "none"


rightPill : List Style
rightPill =
    [ Style "border-top-right-radius" <| px 9999
    , Style "border-bottom-right-radius" <| px 9999
    ]


leftPill : List Style
leftPill =
    [ Style "border-top-left-radius" <| px 9999
    , Style "border-bottom-left-radius" <| px 9999
    ]


frameBackgroundImage : List Style
frameBackgroundImage =
    [ Style "background-position" "center"
    , Style "background-repeat" "no-repeat"
    , Style "background-size" "contain"
    ]


backgroundImage : String -> Style
backgroundImage url =
    Style "background-image" <| "url(" ++ url ++ ")"


backgroundColor : String -> Style
backgroundColor =
    Style "background-color"


background : String -> Style
background =
    Style "background"


widthHeight : Float -> List Style
widthHeight n =
    [ width n
    , height n
    ]


width : Float -> Style
width n =
    Style "width" <| px n


maxWidth : Float -> Style
maxWidth n =
    Style "max-width" <| px n


height : Float -> Style
height h =
    Style "height" <| px h


displayStyle : String -> Style
displayStyle d =
    Style "display" <| d


opacity : Float -> Style
opacity o =
    Style "opacity" <| String.fromFloat o


stroke : String -> Style
stroke =
    Style "stroke"
