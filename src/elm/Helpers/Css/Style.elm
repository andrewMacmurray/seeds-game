module Helpers.Css.Style exposing
    ( Style
    , background
    , backgroundColor
    , backgroundImage
    , borderNone
    , bottomStyle
    , classes
    , color
    , displayStyle
    , emptyStyle
    , frameBackgroundImage
    , heightStyle
    , leftAuto
    , leftPill
    , leftStyle
    , marginAuto
    , marginBottom
    , marginLeft
    , marginRight
    , marginTop
    , maxWidth
    , opacityStyle
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
    , topStyle
    , transform
    , transformOrigin
    , width
    , widthHeight
    )

import Helpers.Css.Transform as Transform exposing (Transform)
import Helpers.Css.Unit exposing (..)
import Html exposing (Attribute, Html)
import Html.Attributes exposing (class)
import Svg
import Svg.Attributes


type Style
    = Style String String


property : String -> String -> Style
property =
    Style


classes : List String -> Attribute msg
classes =
    class << String.join " "


styles : List (List Style) -> Attribute msg
styles =
    renderHtmlStyles << List.concat


style : List Style -> Attribute msg
style =
    renderHtmlStyles


svgStyles : List Style -> Svg.Attribute msg
svgStyles =
    List.map renderSvgStyle
        >> String.join "; "
        >> Svg.Attributes.style


svgStyle : Style -> Svg.Attribute msg
svgStyle =
    Svg.Attributes.style << renderSvgStyle


renderSvgStyle : Style -> String
renderSvgStyle (Style k v) =
    k ++ ":" ++ v


renderHtmlStyles : List Style -> Attribute msg
renderHtmlStyles xs =
    let
        css =
            xs |> List.foldl (\(Style prop val) acc -> String.append acc (prop ++ ":" ++ val ++ ";")) ""
    in
    Html.Attributes.attribute "style" css


emptyStyle : Style
emptyStyle =
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


topStyle : Float -> Style
topStyle n =
    Style "top" <| px n


bottomStyle : Float -> Style
bottomStyle n =
    Style "bottom" <| px n


leftStyle : Float -> Style
leftStyle n =
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
    , heightStyle n
    ]


width : Float -> Style
width n =
    Style "width" <| px n


maxWidth : Float -> Style
maxWidth n =
    Style "max-width" <| px n


heightStyle : Float -> Style
heightStyle height =
    Style "height" <| px height


displayStyle : String -> Style
displayStyle d =
    Style "display" <| d


opacityStyle : Float -> Style
opacityStyle o =
    Style "opacity" <| String.fromFloat o


stroke : String -> Style
stroke =
    Style "stroke"
