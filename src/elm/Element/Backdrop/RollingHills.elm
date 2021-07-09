module Element.Backdrop.RollingHills exposing
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
import Simple.Animation as Animation
import Utils.Cycle as Cycle
import Utils.Geometry exposing (down)
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
    { left : Color
    , middle : Color
    , right : Color
    }


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


purples : Colors
purples =
    { one =
        { left = Palette.purple5
        , middle = Palette.purple1
        , right = Palette.purple5
        }
    , two =
        { left = Palette.purple6
        , middle = Palette.purple2
        , right = Palette.purple6
        }
    , three =
        { left = Palette.purple8
        , middle = Palette.purple1
        , right = Palette.purple8
        }
    , four =
        { left = Palette.purple9
        , middle = Palette.purple2
        , right = Palette.purple9
        }
    }



-- View


animated : AnimatedOptions -> Shape
animated options =
    shape_
        { window = options.window
        , animation = Animated options.delay
        , colors = purples
        }


static : StaticOptions -> Shape
static options =
    shape_
        { window = options.window
        , animation = None
        , colors = purples
        }


shape_ : Options_ -> Shape
shape_ options =
    List.range 0 (maxHills - 1)
        |> List.map (cycleColors options.colors)
        |> List.indexedMap toHillTrio
        |> List.map (hillTrio options)
        |> Shape.group
        |> Shape.moveDown (sceneOffset options.window)


sceneOffset : Window -> number
sceneOffset =
    Window.whenNarrow 400 350


cycleColors : Colors -> Int -> Colors_
cycleColors =
    Cycle.four


toOffset : Int -> Float
toOffset i =
    -430 + toFloat i * 180


type alias HillTrio =
    { order : Int
    , offset : Float
    , left : Color
    , middle : Color
    , right : Color
    }


toHillTrio : Int -> Colors_ -> HillTrio
toHillTrio i colors =
    { order = i
    , offset = toOffset i
    , left = colors.left
    , middle = colors.middle
    , right = colors.right
    }


hillTrio : Options_ -> HillTrio -> Shape
hillTrio options { offset, right, middle, left, order } =
    Shape.group
        [ roundHill offset right options
            |> animateHill options order 400
        , Shape.mirror (roundHill offset left options)
            |> animateHill options order 400
        , middleHill offset options middle
            |> animateHill options order 0
        ]



-- Animation


animateHill : Options_ -> Int -> Animation.Millis -> Shape -> Shape
animateHill options order offset shape =
    case options.animation of
        Animated delay ->
            Shape.animate
                (Animations.fadeIn 600
                    [ Animation.delay (delay + (150 * (5 - order) + offset))
                    ]
                )
                shape

        None ->
            shape



-- Shapes


middleHill : Float -> Options_ -> Color -> Shape
middleHill y options c =
    Shape.circle { fill = c } (middleHill_ y options.window)


roundHill : Float -> Color -> Options_ -> Shape
roundHill y color options =
    Shape.circle { fill = color } (roundHill_ y options.window)


middleHill_ : Float -> Window -> Circle2d Pixels coordinates
middleHill_ y w =
    Circle2d.translateBy (down y)
        (Circle2d.atPoint
            (Point2d.pixels (vw w / 2) (vh w - 60))
            (Pixels.pixels 680)
        )


roundHill_ : Float -> Window -> Circle2d Pixels coordinates
roundHill_ y w =
    Circle2d.translateBy (down (roundHillOffset y w))
        (Circle2d.atPoint
            (point w)
            (Pixels.pixels (roundHillSize w))
        )


roundHillOffset : number -> Window -> number
roundHillOffset y =
    Window.whenNarrow (y - 50) y


roundHillSize : Window -> Float
roundHillSize w =
    clamp 385 1800 (vw w / 2)


point : Window -> Point2d Pixels coordinates
point w =
    Point2d.along (axis w) (Pixels.pixels (vw w / 2))


axis : Window -> Axis2d Pixels coordinates
axis w =
    Axis2d.withDirection
        (Direction2d.degrees (vw w / 50))
        (Point2d.pixels (vw w / 2) (vh w / 2))
