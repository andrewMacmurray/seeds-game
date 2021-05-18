module Utils.Geometry exposing
    ( down
    , mirror
    )

import Axis2d exposing (Axis2d)
import Direction2d
import Geometry.Svg as Svg
import Pixels exposing (Pixels)
import Point2d exposing (Point2d)
import Svg exposing (Svg)
import Vector2d exposing (Vector2d)
import Window exposing (Window, vh, vw)



-- Vector


down : Float -> Vector2d Pixels coordinates
down =
    Vector2d.pixels 0



-- Mirror


mirror : Window -> Svg msg -> Svg msg
mirror window =
    Svg.mirrorAcross (centerScreen window)


centerScreen : Window -> Axis2d Pixels coordinates
centerScreen window =
    Axis2d.withDirection Direction2d.y (center window)


center : Window -> Point2d Pixels coordinates
center window =
    Point2d.pixels (vw window / 2) (vh window / 2)
