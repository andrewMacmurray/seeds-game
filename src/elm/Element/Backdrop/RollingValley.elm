module Element.Backdrop.RollingValley exposing
    ( animated
    , static
    )

import Axis2d exposing (Axis2d)
import Circle2d exposing (Circle2d)
import Direction2d
import Element exposing (..)
import Element.Animations as Animations
import Element.Palette as Palette
import Geometry.Shape as Shape exposing (Shape)
import Pixels exposing (Pixels)
import Point2d exposing (Point2d)
import Simple.Animation as Animation exposing (Animation)
import Utils.Cycle as Cycle
import Utils.Geometry as Geometry
import Window exposing (Window, vh, vw)



-- Hills


type alias AnimatedOptions =
    { window : Window
    , delay : Animation.Millis
    }


type alias StaticOptions =
    { window : Window
    }


type alias Colors =
    Cycle.Four Colors_


type alias Colors_ =
    ( Color, Color )


type alias Options_ =
    { window : Window
    , colors : Colors
    , animation : HillsAnimation
    }


type HillsAnimation
    = None
    | Animated Animation.Millis


maxHills : number
maxHills =
    6



-- Colors


yellows : Colors
yellows =
    { one = ( Palette.yellow7, Palette.yellow6 )
    , two = ( Palette.yellow6, Palette.yellow4 )
    , three = ( Palette.yellow7, Palette.yellow8 )
    , four = ( Palette.yellow4, Palette.yellow5 )
    }



-- View


animated : AnimatedOptions -> Shape
animated options =
    shape
        { window = options.window
        , colors = yellows
        , animation = Animated options.delay
        }


static : StaticOptions -> Shape
static options =
    shape
        { window = options.window
        , colors = yellows
        , animation = None
        }


shape : Options_ -> Shape
shape options =
    List.range 0 (maxHills - 1)
        |> List.map (cycleColors options)
        |> List.indexedMap (toHills options)
        |> List.concat
        |> Shape.group
        |> Shape.moveUp (Window.whenNarrow 250 200 options.window)


toHills : Options_ -> Int -> ( Color, Color ) -> List Shape
toHills options i ( l, r ) =
    hillPair options
        { order = i
        , offset = toFloat i * 150
        , left = l
        , right = r
        }


type alias Hill =
    { order : Int
    , offset : Float
    , left : Color
    , right : Color
    }


cycleColors : Options_ -> Int -> Colors_
cycleColors options =
    Cycle.four options.colors


hillPair : Options_ -> Hill -> List Shape
hillPair options hillOptions =
    [ { fill = hillOptions.right
      , offset = hillOptions.offset
      , window = options.window
      }
        |> hill
        |> animateHill options hillOptions
    , { fill = hillOptions.left
      , offset = hillOptions.offset
      , window = options.window
      }
        |> hill
        |> Shape.mirror
        |> animateHill options hillOptions
    ]


animateHill : Options_ -> Hill -> Shape -> Shape
animateHill options hillOptions shape_ =
    case options.animation of
        Animated delay ->
            Shape.animate (fadeIn delay hillOptions) shape_

        None ->
            shape_


fadeIn : Animation.Millis -> Hill -> Animation
fadeIn delay options =
    Animations.fadeIn 300
        [ Animation.delay (delay + ((6 - options.order) * 150))
        ]


hill : { fill : Color, offset : Float, window : Window } -> Shape
hill { fill, offset, window } =
    Shape.circle { fill = fill } (hill_ offset window)


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
    Point2d.along
        (axis w)
        (Pixels.pixels (vw w / pointFactor w))


pointFactor : Window -> Float
pointFactor =
    Window.whenNarrow 1.4 2


axis : Window -> Axis2d Pixels coordinates
axis w =
    Axis2d.withDirection
        (Direction2d.degrees 50)
        (Point2d.pixels (vw w / 2) (vh w / 2))
