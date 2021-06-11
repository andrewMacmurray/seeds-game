module Utils.Html.Style exposing
    ( absolute
    , background
    , center
    , height
    , opacity
    , pointer
    , rounded
    , splitBackground
    , transform
    , width
    , z
    )

import Css.Transform as Transform exposing (Transform)
import Element
import Html exposing (Attribute)
import Html.Attributes exposing (style)
import Utils.Background as Background
import Utils.Color as Color
import Utils.Unit exposing (px)


absolute : Attribute msg
absolute =
    style "position" "absolute"


width : Int -> Attribute msg
width n =
    style "width" (px n)


height : Int -> Attribute msg
height n =
    style "height" (px n)


rounded : Int -> Attribute msg
rounded n =
    style "border-radius" (px n)


opacity : Float -> Attribute msg
opacity n =
    style "opacity" (String.fromFloat n)


pointer : Attribute msg
pointer =
    style "cursor" "pointer"


transform : List Transform -> Attribute msg
transform xs =
    style "transform" (Transform.render xs)


background : Element.Color -> Attribute msg
background c =
    style "background" (Color.toString c)


z : Int -> Attribute msg
z n =
    style "z-index" (String.fromInt n)


center : List (Attribute msg) -> List (Attribute msg)
center =
    List.append
        [ top 0
        , left 0
        , right 0
        , bottom 0
        , marginAuto
        ]


top : Int -> Attribute msg
top n =
    style "top" (px n)


bottom : Int -> Attribute msg
bottom n =
    style "bottom" (px n)


left : Int -> Attribute msg
left n =
    style "left" (px n)


right : Int -> Attribute msg
right n =
    style "right" (px n)


marginAuto : Attribute msg
marginAuto =
    style "margin" "auto"


splitBackground : Background.Split -> Attribute msg
splitBackground split =
    style "background" (Background.splitGradient split)
