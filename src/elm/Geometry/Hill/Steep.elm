module Geometry.Hill.Steep exposing (hillPair)

import Axis2d exposing (Axis2d)
import Direction2d
import Element exposing (..)
import Element.Icon.Tree.Fir as Fir
import Geometry.Shape as Shape exposing (Shape)
import Pixels exposing (Pixels)
import Point2d exposing (Point2d)
import Polygon2d exposing (Polygon2d)
import Simple.Animation exposing (Animation)
import Utils.Geometry exposing (down)
import Window exposing (Window, vh, vw)



-- Steep Hill


type alias Options =
    { window : Window
    , offset : Float
    , left : Side
    , right : Side
    , animation : Maybe Animation
    }


type alias Side =
    { color : Color
    }


type alias Hill =
    { offset : Float
    , color : Color
    , window : Window
    , animation : Maybe Animation
    }



-- Shape


hillPair : Options -> List (Shape msg)
hillPair options =
    [ hill
        { offset = options.offset
        , color = options.right.color
        , window = options.window
        , animation = options.animation
        }
    , mirrored
        { offset = options.offset
        , color = options.left.color
        , window = options.window
        , animation = options.animation
        }
    ]


mirrored : Hill -> Shape msg
mirrored =
    Shape.mirror << hill


hill : Hill -> Shape msg
hill options =
    animate options
        (Shape.group
            [ sprite options
            , Shape.polygon { fill = options.color } (hill_ options.offset options.window)
            ]
        )


animate : { a | animation : Maybe Animation } -> Shape msg -> Shape msg
animate options shape =
    options.animation
        |> Maybe.map (\a -> Shape.animate a shape)
        |> Maybe.withDefault shape


sprite : Hill -> Shape msg
sprite options =
    Shape.moveDown (options.offset - 75)
        (Shape.placeAt
            (Point2d.along
                (axis options.window)
                (Pixels.pixels 200)
            )
            Fir.alive
        )


hill_ : Float -> Window -> Polygon2d Pixels coordinates
hill_ y window =
    Polygon2d.translateBy (down y)
        (Polygon2d.singleLoop
            [ p1 window
            , p2 window
            , Point2d.translateBy (down hillHeight) (p2 window)
            , Point2d.translateBy (down hillHeight) (p1 window)
            ]
        )


hillHeight : number
hillHeight =
    300


p1 : Window -> Point2d Pixels coordinates
p1 window =
    Point2d.along (axis window) (Pixels.pixels (vw window))


p2 : Window -> Point2d Pixels coordinates
p2 window =
    Point2d.along (axis window) (Pixels.pixels -(vw window))


axis : Window -> Axis2d Pixels coordinates
axis w =
    Axis2d.withDirection
        (Direction2d.degrees -26)
        (Point2d.pixels (vw w / 2) (vh w - 450))
