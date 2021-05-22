module Scene.Garden.Chrysanthemum exposing (hills)

import Axis2d exposing (Axis2d)
import Circle2d exposing (Circle2d)
import Direction2d
import Element exposing (Color)
import Element.Palette as Palette
import Pixels exposing (Pixels)
import Point2d exposing (Point2d)
import Scene.Garden.Shape as Shape exposing (Shape)
import Utils.Geometry exposing (down)
import Window exposing (Window, vh, vw)


hills : Window -> Shape
hills window =
    Shape.moveDown (Window.whenNarrow 130 80 window)
        (Shape.group
            [ roundHill -200 Palette.purple10 window
            , Shape.mirror (roundHill -200 Palette.purple7 window)
            , middleHill -250 window Palette.purple8
            , roundHill 0 Palette.purple3 window
            , Shape.mirror (roundHill 0 Palette.purple2 window)
            , middleHill -100 window Palette.purple1
            , roundHill 300 Palette.purple9 window
            , Shape.mirror (roundHill 300 Palette.purple7 window)
            , middleHill 250 window Palette.purple3
            ]
        )


middleHill : Float -> Window -> Color -> Shape
middleHill y w c =
    Shape.circle { fill = c } (middleHill_ y w)


roundHill : Float -> Color -> Window -> Shape
roundHill y color window =
    Shape.circle { fill = color } (roundHill_ y window)


middleHill_ : Float -> Window -> Circle2d Pixels coordinates
middleHill_ y w =
    Circle2d.translateBy (down y)
        (Circle2d.atPoint
            (Point2d.pixels (vw w / 2) (vh w - 60))
            (Pixels.pixels 500)
        )


roundHill_ : Float -> Window -> Circle2d Pixels coordinates
roundHill_ y w =
    let
        r =
            clamp 400 1800 (vw w / 2)
    in
    Circle2d.translateBy (down y)
        (Circle2d.atPoint
            (point w)
            (Pixels.pixels r)
        )


point : Window -> Point2d Pixels coordinates
point w =
    Point2d.along (axis w) (Pixels.pixels (vw w / 2))


axis : Window -> Axis2d Pixels coordinates
axis w =
    Axis2d.withDirection
        (Direction2d.degrees (vw w / 50))
        (Point2d.pixels (vw w / 2) (vh w / 2))
