module Scene.Summary.Chrysanthemum exposing
    ( background
    , view
    )

import Axis2d exposing (Axis2d)
import Circle2d exposing (Circle2d)
import Direction2d
import Element exposing (Color)
import Element.Palette as Palette
import Geometry.Shape as Shape exposing (Shape)
import Pixels exposing (Pixels)
import Point2d exposing (Point2d)
import Svg exposing (Svg)
import Utils.Geometry exposing (down)
import Window exposing (Window, vh, vw)



-- Background


background : Element.Color
background =
    Palette.purple4



-- View


view : Window -> Svg msg
view window =
    Shape.window window [] (shape window)


shape : Window -> Shape
shape window =
    List.range 0 3
        |> List.map (cycleHills >> hillTrio window)
        |> List.concat
        |> Shape.group
        |> Shape.moveDown 350


cycleHills : Int -> HillTrio
cycleHills i =
    case modBy 4 i of
        0 ->
            { offset = toOffset i
            , left = Palette.purple5
            , middle = Palette.purple1
            , right = Palette.purple5
            }

        1 ->
            { offset = toOffset i
            , left = Palette.purple6
            , middle = Palette.purple2
            , right = Palette.purple6
            }

        2 ->
            { offset = toOffset i
            , left = Palette.purple8
            , middle = Palette.purple1
            , right = Palette.purple8
            }

        _ ->
            { offset = toOffset i
            , left = Palette.purple9
            , middle = Palette.purple3
            , right = Palette.purple9
            }


toOffset : Int -> Float
toOffset i =
    -430 + toFloat i * 220


type alias HillTrio =
    { offset : Float
    , left : Color
    , middle : Color
    , right : Color
    }


hillTrio : Window -> HillTrio -> List Shape
hillTrio window { offset, right, middle, left } =
    [ roundHill offset right window
    , Shape.mirror (roundHill offset left window)
    , middleHill offset window middle
    ]


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
            (Pixels.pixels 680)
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
