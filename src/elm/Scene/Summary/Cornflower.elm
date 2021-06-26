module Scene.Summary.Cornflower exposing
    ( flowers
    , hills
    )

import Axis2d exposing (Axis2d)
import Circle2d exposing (Circle2d)
import Direction2d
import Element exposing (..)
import Element.Animations as Animations
import Element.Flower.Cornflower as Cornflower
import Element.Palette as Palette
import Element.Scale as Scale
import Geometry.Shape as Shape exposing (Shape)
import Pixels exposing (Pixels)
import Point2d exposing (Point2d)
import Scene.Garden.Cornflower.Sprites as Ladybird
import Simple.Animation as Animation exposing (Animation)
import Svg exposing (Svg)
import Utils.Animated as Animated
import Utils.Function exposing (apply)
import Utils.Geometry as Geometry
import Window exposing (Window, vh, vw)



-- Delays


type alias Delays =
    { flowers : Animation.Millis
    , sprites : Animation.Millis
    }


delays : Delays
delays =
    { flowers = 1300
    , sprites = 1500
    }



-- Flowers


flowers : Element msg
flowers =
    column
        [ centerX
        , spacing -Scale.extraLarge
        ]
        [ el
            [ moveRight 10
            , ladybird { angle = 35, x = 35, y = 30, delay = 0 }
            , ladybird { angle = 90, x = 120, y = 180, delay = 1300 }
            , ladybird { angle = 155, x = 210, y = 90, delay = 600 }
            ]
            (flower { size = 215, delay = 0 })
        , row []
            [ el [ moveLeft 40 ] (flower { size = 120, delay = 300 })
            , el [ moveRight 40 ] (flower { size = 120, delay = 600 })
            ]
        ]


type alias Ladybird =
    { angle : Float
    , x : Float
    , y : Float
    , delay : Animation.Millis
    }


ladybird : Ladybird -> Attribute msg
ladybird { angle, x, y, delay } =
    inFront
        (Animated.el (fadeLadybird delay)
            [ rotate (degrees angle)
            , moveRight x
            , moveDown y
            ]
            (Ladybird.ladybird delay)
        )


fadeLadybird : Animation.Millis -> Animation
fadeLadybird delay =
    Animations.fadeIn 500
        [ Animation.delay (delays.flowers + delays.sprites + (delay // 2))
        ]


type alias Flower =
    { size : Int
    , delay : Animation.Millis
    }


flower : Flower -> Element msg
flower options =
    el [ width (px options.size) ] (html (Cornflower.animated (delays.flowers + options.delay)))



-- Hills


hills : Window -> Svg msg
hills window =
    Shape.fullScreen window (hills_ window)


hills_ : Window -> Shape
hills_ window =
    List.range 0 maxHills
        |> List.map cycleColors
        |> List.indexedMap toHills
        |> List.concatMap (apply window)
        |> Shape.group
        |> Shape.moveUp (Window.whenNarrow 250 200 window)


maxHills : number
maxHills =
    5


toHills : Int -> ( Color, Color ) -> Window -> List Shape
toHills i ( l, r ) =
    hillPair
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


hillPair : Hill -> Window -> List Shape
hillPair options window =
    [ { fill = options.right
      , offset = options.offset
      , window = window
      }
        |> hill
        |> animateHill options
    , { fill = options.left
      , offset = options.offset
      , window = window
      }
        |> hill
        |> Shape.mirror
        |> animateHill options
    ]


animateHill : Hill -> Shape -> Shape
animateHill options =
    Shape.animate
        (Animations.fadeIn 300
            [ Animation.delay ((6 - options.order) * 150)
            ]
        )


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
