module Utils.Style exposing
    ( absolute
    , background
    , center
    , fixed
    , fullWidth
    , height
    , opacity
    , originBottom
    , pointer
    , relative
    , rounded
    , splitBackground
    , top
    , transform
    , width
    , zIndex
    )

import Element
import Html exposing (Attribute)
import Html.Attributes exposing (style)
import Utils.Background as Background
import Utils.Color as Color
import Utils.Transform as Transform exposing (Transform)
import Utils.Unit as Unit


absolute : Attribute msg
absolute =
    position_ "absolute"


relative : Attribute msg
relative =
    position_ "relative"


fixed : Attribute msg
fixed =
    position_ "fixed"


width : Int -> Attribute msg
width =
    px_ "width"


fullWidth : Attribute msg
fullWidth =
    style "width" "100%"


height : Int -> Attribute msg
height =
    px_ "height"


rounded : Int -> Attribute msg
rounded =
    px_ "border-radius"


opacity : Float -> Attribute msg
opacity n =
    style "opacity" (String.fromFloat n)


pointer : Attribute msg
pointer =
    style "cursor" "pointer"


transform : List Transform -> Attribute msg
transform xs =
    style "transform" (Transform.toString xs)


background : Element.Color -> Attribute msg
background c =
    style "background" (Color.toString c)


zIndex : Int -> Attribute msg
zIndex n =
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
top =
    px_ "top"


bottom : Int -> Attribute msg
bottom =
    px_ "bottom"


left : Int -> Attribute msg
left =
    px_ "left"


right : Int -> Attribute msg
right =
    px_ "right"


marginAuto : Attribute msg
marginAuto =
    style "margin" "auto"


splitBackground : Background.Split -> Attribute msg
splitBackground split =
    style "background" (Background.splitGradient split)


originBottom : Attribute msg
originBottom =
    transformOrigin "bottom" "center"



-- Internal


transformOrigin : String -> String -> Attribute msg
transformOrigin v h =
    style "transform-origin" (v ++ " " ++ h)


position_ : String -> Attribute msg
position_ =
    style "position"


px_ : String -> Int -> Attribute msg
px_ prop n =
    style prop (Unit.px n)
