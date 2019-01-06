module Helpers.Svg exposing
    ( Point
    , cx_
    , cy_
    , height_
    , point
    , points_
    , r_
    , scaled
    , strokeWidth_
    , translated
    , viewBox_
    , width_
    , windowViewBox_
    , x_
    , y_
    )

import Css.Style as Style
import Css.Transform as Transform
import Svg exposing (Attribute)
import Svg.Attributes exposing (..)


windowViewBox_ window =
    viewBox_ 0 0 (toFloat window.width) (toFloat window.height)


translated x y el =
    Svg.g [ Style.svgStyle [ Style.transform [ Transform.translate x y ] ] ] [ el ]


scaled n el =
    Svg.g [ Style.svgStyle [ Style.transform [ Transform.scale n ] ] ] [ el ]


points_ =
    List.map (\pt -> String.fromFloat pt.x ++ "," ++ String.fromFloat pt.y)
        >> String.join " "
        >> points


point =
    Point


type alias Point =
    { x : Float
    , y : Float
    }


cx_ : Float -> Attribute msg
cx_ =
    cx << String.fromFloat


cy_ : Float -> Attribute msg
cy_ =
    cy << String.fromFloat


height_ =
    height << String.fromFloat


width_ =
    width << String.fromFloat


x_ : Float -> Attribute msg
x_ =
    x << String.fromFloat


y_ : Float -> Attribute msg
y_ =
    y << String.fromFloat


r_ : Float -> Attribute msg
r_ =
    r << String.fromFloat


strokeWidth_ : Float -> Attribute msg
strokeWidth_ =
    strokeWidth << String.fromFloat


viewBox_ : Float -> Float -> Float -> Float -> Attribute msg
viewBox_ x y w h =
    viewBox <| String.join " " <| List.map String.fromFloat [ x, y, w, h ]
