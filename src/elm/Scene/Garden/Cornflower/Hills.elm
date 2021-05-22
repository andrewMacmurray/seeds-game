module Scene.Garden.Cornflower.Hills exposing (shape)

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


shape : Window -> Shape
shape window =
    List.range 0 3
        |> List.map cycleColors
        |> List.indexedMap toHills
        |> List.concatMap (apply window)
        |> Shape.group
        |> Shape.moveDown (Window.whenNarrow -250 -80 window)


toHills : Int -> ( Color, Color ) -> Window -> List Shape
toHills i ( l, r ) =
    hillPair
        { offset = toFloat i * 150
        , left = l
        , right = r
        }


cycleColors : Int -> ( Color, Color )
cycleColors i =
    case modBy 8 i of
        0 ->
            ( Palette.yellow7, Palette.yellow6 )

        1 ->
            ( Palette.yellow6, Palette.yellow3 )

        2 ->
            ( Palette.yellow7, Palette.yellow8 )

        3 ->
            ( Palette.yellow3, Palette.yellow5 )

        4 ->
            ( Palette.yellow1, Palette.yellow2 )

        5 ->
            ( Palette.yellow3, Palette.yellow4 )

        _ ->
            ( Palette.yellow8, Palette.yellow10 )


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
            (Pixels.pixels (vw w / 1.75))
        )


point : Window -> Point2d Pixels coordinates
point w =
    Point2d.along (axis w) (Pixels.pixels (vw w / 2))


axis : Window -> Axis2d Pixels coordinates
axis w =
    Axis2d.withDirection
        (Direction2d.degrees 50)
        (Point2d.pixels (vw w / 2) (vh w / 2))


apply : a -> (a -> b) -> b
apply =
    (|>)
