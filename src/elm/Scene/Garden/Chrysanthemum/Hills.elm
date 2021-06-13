module Scene.Garden.Chrysanthemum.Hills exposing (shape)

import Axis2d exposing (Axis2d)
import Circle2d exposing (Circle2d)
import Direction2d
import Element exposing (Color)
import Element.Palette as Palette
import Geometry.Shape as Shape exposing (Shape)
import Pixels exposing (Pixels)
import Point2d exposing (Point2d)
import Utils.Function exposing (apply)
import Utils.Geometry exposing (down)
import Window exposing (Window, vh, vw)


shape : Window -> Shape
shape window =
    [ hillTrio
        { offset = -250
        , adjustHills = 125
        , left = Palette.purple1
        , middle = Palette.purple8
        , right = Palette.purple2
        }
    , hillTrio
        { offset = -100
        , adjustHills = 200
        , left = Palette.purple3
        , middle = Palette.purple1
        , right = Palette.purple4
        }
    , hillTrio
        { offset = 250
        , adjustHills = 50
        , left = Palette.purple9
        , middle = Palette.purple3
        , right = Palette.purple7
        }
    ]
        |> List.map (apply window)
        |> List.concat
        |> Shape.group
        |> Shape.moveDown (Window.whenNarrow 130 120 window)


type alias HillTrio =
    { offset : Float
    , adjustHills : Float
    , left : Color
    , middle : Color
    , right : Color
    }


hillTrio : HillTrio -> Window -> List Shape
hillTrio { offset, adjustHills, left, middle, right } window =
    [ roundHill (offset + adjustHills) left window
    , Shape.mirror (roundHill (offset + adjustHills) right window)
    , middleHill offset window middle
    ]


middleHill : Float -> Window -> Color -> Shape
middleHill y w c =
    Shape.circle { fill = c } (middleHill_ y w)


roundHill : Float -> Color -> Window -> Shape
roundHill y color window =
    Shape.circle { fill = color } (roundHill_ y window)
        |> Shape.hideIf (Window.isNarrow window)


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
