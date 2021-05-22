module Scene.Garden.Cornflower exposing (hills)

import Axis2d exposing (Axis2d)
import Circle2d exposing (Circle2d)
import Direction2d
import Element exposing (Color)
import Element.Palette as Palette
import Pixels exposing (Pixels)
import Point2d exposing (Point2d)
import Scene.Garden.Shape as Shape exposing (Shape)
import Utils.Geometry as Geometry
import Window exposing (Window, vh, vw)


hills : Window -> Shape
hills window =
    List.range 0 6
        |> List.map cycleColors
        |> List.indexedMap toHills
        |> List.concatMap (apply window)
        |> Shape.group
        |> Shape.moveDown -120


toHills : Int -> ( Color, Color ) -> Window -> List Shape
toHills i ( l, r ) =
    hillPair
        { offset = toFloat i * 100
        , left = l
        , right = r
        }


cycleColors i =
    case modBy 8 i of
        0 ->
            ( Palette.blue2, Palette.yellow7 )

        1 ->
            ( Palette.blue3, Palette.yellow6 )

        2 ->
            ( Palette.blue4, Palette.yellow8 )

        3 ->
            ( Palette.blue5, Palette.yellow3 )

        4 ->
            ( Palette.yellow6, Palette.blue2 )

        5 ->
            ( Palette.yellow3, Palette.blue3 )

        6 ->
            ( Palette.yellow8, Palette.blue4 )

        _ ->
            ( Palette.yellow7, Palette.blue5 )


hillPair : { offset : Float, left : Color, right : Color } -> Window -> List Shape
hillPair { offset, left, right } window =
    [ hill { fill = left, offset = offset } window
    , Shape.mirror (hill { fill = right, offset = offset } window)
    ]


hill { fill, offset } w =
    Shape.circle { fill = fill } (hill_ offset w)


hill_ : Float -> Window -> Circle2d Pixels coordinates
hill_ offset w =
    Circle2d.translateBy (Geometry.down offset)
        (Circle2d.atPoint
            (point w)
            (Pixels.pixels (vw w / 1.75))
        )


point : Window -> Point2d Pixels coordinates
point w =
    Point2d.along (axis w) (Pixels.pixels (vw w / 2))


axis : Window -> Axis2d Pixels coordinates
axis w =
    Axis2d.withDirection
        (Direction2d.degrees 45)
        (Point2d.pixels (vw w / 2) (vh w / 2))


apply =
    (|>)
