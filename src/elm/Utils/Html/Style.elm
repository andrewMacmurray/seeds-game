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
import Utils.Unit as Unit


absolute : Attribute msg
absolute =
    position_ "absolute"


width : Int -> Attribute msg
width =
    pixels_ "width"


height : Int -> Attribute msg
height =
    pixels_ "height"


rounded : Int -> Attribute msg
rounded =
    pixels_ "border-radius"


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
top =
    pixels_ "top"


bottom : Int -> Attribute msg
bottom =
    pixels_ "bottom"


left : Int -> Attribute msg
left =
    pixels_ "left"


right : Int -> Attribute msg
right =
    pixels_ "right"


marginAuto : Attribute msg
marginAuto =
    style "margin" "auto"


splitBackground : Background.Split -> Attribute msg
splitBackground split =
    style "background" (Background.splitGradient split)



-- Internal


position_ : String -> Attribute msg
position_ =
    style "position"


pixels_ : String -> Int -> Attribute msg
pixels_ prop n =
    style prop (Unit.px n)
