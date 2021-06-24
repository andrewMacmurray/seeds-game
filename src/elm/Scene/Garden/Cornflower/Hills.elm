module Scene.Garden.Cornflower.Hills exposing (shape)

import Axis2d exposing (Axis2d)
import Circle2d exposing (Circle2d)
import Direction2d
import Element exposing (Color)
import Element.Palette as Palette
import Geometry.Shape as Shape exposing (Shape)
import Pixels exposing (Pixels)
import Point2d exposing (Point2d)
import Utils.Function exposing (apply)
import Utils.Geometry as Geometry
import Window exposing (Window, vh, vw)


shape : Window -> Shape
shape window =
    List.range 0 4
        |> List.map cycleColors
        |> List.indexedMap toHills
        |> List.concatMap (apply window)
        |> Shape.group
        |> Shape.moveDown (Window.whenNarrow -250 -100 window)


toHills : Int -> ( Color, Color ) -> Window -> List Shape
toHills i ( l, r ) =
    hillPair
        { offset = toFloat i * 150
        , left = l
        , right = r
        }


cycleColors : Int -> ( Color, Color )
cycleColors i =
    case modBy 4 i of
        0 ->
            ( Palette.yellow7, Palette.yellow6 )

        1 ->
            ( Palette.yellow6, Palette.yellow3 )

        2 ->
            ( Palette.yellow7, Palette.yellow8 )

        _ ->
            ( Palette.yellow3, Palette.yellow5 )


hillPair : { offset : Float, left : Color, right : Color } -> Window -> List Shape
hillPair { offset, left, right } window =
    [ hill
        { fill = right
        , offset = offset
        }
        window
    , Shape.mirror
        (hill
            { fill = left
            , offset = offset
            }
            window
        )
    ]


hill : { fill : Color, offset : Float } -> Window -> Shape
hill { fill, offset } w =
    Shape.circle { fill = fill } (hill_ offset w)


hill_ : Float -> Window -> Circle2d Pixels coordinates
hill_ offset w =
    Circle2d.translateBy (Geometry.down offset)
        (Circle2d.atPoint
            (point w)
            (Pixels.pixels (vw w / radiusFactor w))
        )


radiusFactor : Window -> Float
radiusFactor =
    Window.whenNarrow 1.2 1.75


point : Window -> Point2d Pixels coordinates
point w =
    Point2d.along (axis w) (Pixels.pixels (vw w / pointFactor w))


pointFactor : Window -> Float
pointFactor =
    Window.whenNarrow 1.4 2


axis : Window -> Axis2d Pixels coordinates
axis w =
    Axis2d.withDirection
        (Direction2d.degrees 50)
        (Point2d.pixels (vw w / 2) (vh w / 2))
