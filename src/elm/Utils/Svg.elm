module Utils.Svg exposing
    ( Point
    , cx_
    , cy_
    , disableTouch
    , fill_
    , full
    , fullWidth
    , g_
    , height_
    , originCenter_
    , point
    , points_
    , r_
    , rx_
    , ry_
    , scaled
    , strokeWidth_
    , stroke_
    , transformOrigin_
    , translated
    , viewBox_
    , width_
    , window
    , x_
    , y_
    )

import Element
import Svg exposing (Attribute, Svg)
import Svg.Attributes exposing (..)
import Utils.Color as Color
import Utils.Style as Style
import Utils.Transform as Transform
import Utils.Unit as Unit
import Window exposing (Window, vh, vw)


fill_ : Element.Color -> Attribute msg
fill_ color =
    Svg.Attributes.fill (Color.toString color)


g_ : List (Attribute msg) -> List (Svg msg) -> Svg msg
g_ attrs =
    Svg.g (translate0 :: attrs)


translate0 : Attribute msg
translate0 =
    Style.transform [ Transform.translate 0 0 ]


window : Window -> List (Attribute msg) -> List (Svg.Svg msg) -> Svg msg
window w attrs =
    Svg.svg
        (List.append
            [ windowViewBox_ w
            , width_ (vw w)
            , height_ (vh w)
            ]
            attrs
        )


full : List (Attribute msg) -> List (Svg msg) -> Svg msg
full attrs =
    Svg.svg
        (List.append
            [ fullHeight
            , fullWidth
            ]
            attrs
        )


windowViewBox_ : Window -> Attribute msg
windowViewBox_ w =
    viewBox_ 0 0 (toFloat w.width) (toFloat w.height)


translated : Float -> Float -> Svg.Svg msg -> Svg.Svg msg
translated x y el =
    Svg.g [ Style.transform [ Transform.translate x y ] ] [ el ]


scaled : Float -> Svg.Svg msg -> Svg.Svg msg
scaled n el =
    Svg.g [ Style.transform [ Transform.scale n ] ] [ el ]


points_ : List Point -> Attribute msg
points_ =
    List.map (\pt -> String.fromFloat pt.x ++ "," ++ String.fromFloat pt.y)
        >> String.join " "
        >> points


point : Float -> Float -> Point
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


height_ : Float -> Attribute msg
height_ =
    height << String.fromFloat


fullHeight : Attribute msg
fullHeight =
    height "100%"


fullWidth : Attribute msg
fullWidth =
    width "100%"


width_ : Float -> Attribute msg
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


rx_ : Float -> Attribute msg
rx_ =
    rx << String.fromFloat


ry_ : Float -> Attribute msg
ry_ =
    ry << String.fromFloat


stroke_ : Element.Color -> Attribute msg
stroke_ =
    stroke << Color.toString


strokeWidth_ : Float -> Attribute msg
strokeWidth_ =
    strokeWidth << String.fromFloat


viewBox_ : Float -> Float -> Float -> Float -> Attribute msg
viewBox_ x y w h =
    viewBox (String.join " " (List.map String.fromFloat [ x, y, w, h ]))


transformOrigin_ : Float -> Float -> String
transformOrigin_ x y =
    "transform-origin: " ++ Unit.px_ x ++ " " ++ Unit.px_ y


originCenter_ : String
originCenter_ =
    "transform-origin: center"


disableTouch : Attribute msg
disableTouch =
    Svg.Attributes.class "touch-disabled"
