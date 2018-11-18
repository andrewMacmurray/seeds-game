module Helpers.Svg exposing
    ( Point
    , cx_
    , cy_
    , height_
    , point
    , points_
    , r_
    , viewBox_
    , width_
    , x_
    , y_
    )

import Svg exposing (Attribute)
import Svg.Attributes exposing (..)


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


viewBox_ : Int -> Int -> Int -> Int -> Attribute msg
viewBox_ x y w h =
    viewBox <| String.join " " <| List.map String.fromInt [ x, y, w, h ]
