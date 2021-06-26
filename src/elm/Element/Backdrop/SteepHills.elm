module Element.Backdrop.SteepHills exposing
    ( Colors
    , animated
    , green
    , shape_
    , static
    )

import Axis2d exposing (Axis2d)
import Direction2d
import Element exposing (..)
import Element.Animations as Animations
import Element.Palette as Palette
import Geometry.Shape as Shape exposing (Shape)
import Pixels exposing (Pixels)
import Point2d
import Polygon2d exposing (Polygon2d)
import Simple.Animation as Animation exposing (Animation)
import Utils.Geometry exposing (down)
import Window exposing (Window, vh, vw)



-- Hills


type alias AnimatedOptions =
    { window : Window
    , hills : Int
    , delay : Animation.Millis
    , colors : Colors
    }


type alias StaticOptions =
    { window : Window
    , hills : Int
    , colors : Colors
    }


type alias Colors =
    { one : Colors_
    , two : Colors_
    , three : Colors_
    }


type alias Colors_ =
    ( Color, Color )


type alias Options_ =
    { window : Window
    , hills : Int
    , colors : Colors
    , animation : HillsAnimation
    }


type HillsAnimation
    = None
    | Animated Animation.Millis



-- Colors


green : Colors
green =
    { one = ( Palette.green8, Palette.green3 )
    , two = ( Palette.green4, Palette.green2 )
    , three = ( Palette.green1, Palette.green6 )
    }



-- View


animated : AnimatedOptions -> Shape
animated options =
    shape_
        { window = options.window
        , hills = options.hills
        , colors = options.colors
        , animation = Animated options.delay
        }


static : StaticOptions -> Shape
static options =
    shape_
        { window = options.window
        , hills = options.hills
        , colors = options.colors
        , animation = None
        }


shape_ : Options_ -> Shape
shape_ options =
    List.range 0 (options.hills - 1)
        |> List.map (cycleColors options)
        |> List.indexedMap toHillConfig
        |> List.map (toHillPair options)
        |> List.concat
        |> List.reverse
        |> Shape.group
        |> Shape.moveUp 50


type alias HillConfig =
    { order : Int
    , offset : Float
    , left : Color
    , right : Color
    }


toHillConfig : Int -> ( Color, Color ) -> HillConfig
toHillConfig i ( left, right ) =
    { order = i
    , offset = 750 - toFloat (i * 180)
    , left = left
    , right = right
    }


toHillPair : Options_ -> HillConfig -> List Shape
toHillPair options config =
    [ { offset = config.offset
      , color = config.right
      , window = options.window
      }
        |> hill
        |> withAnimation options config
    , { offset = config.offset
      , color = config.left
      , window = options.window
      }
        |> mirrored
        |> withAnimation options config
    ]



-- Animate


withAnimation : Options_ -> HillConfig -> Shape -> Shape
withAnimation options config shape =
    case options.animation of
        Animated delay ->
            Shape.animate (fadeIn delay config) shape

        None ->
            shape


fadeIn : Animation.Millis -> HillConfig -> Animation
fadeIn delay config =
    Animations.fadeIn 500
        [ Animation.delay (fadeHillDelay delay config)
        ]


fadeHillDelay : Animation.Millis -> HillConfig -> Animation.Millis
fadeHillDelay delay config =
    delay + (config.order * 150)



-- Colors


cycleColors : Options_ -> Int -> ( Color, Color )
cycleColors options i =
    case modBy 3 i of
        0 ->
            options.colors.one

        1 ->
            options.colors.two

        _ ->
            options.colors.three



-- Shape


mirrored : { offset : Float, color : Color, window : Window } -> Shape
mirrored =
    Shape.mirror << hill


hill : { offset : Float, color : Element.Color, window : Window } -> Shape
hill { offset, color, window } =
    Shape.polygon { fill = color } (hill_ offset window)


hill_ : Float -> Window -> Polygon2d Pixels coordinates
hill_ y window =
    let
        ax =
            axis window

        p1 =
            Point2d.along ax (Pixels.pixels (toFloat window.width))

        p2 =
            Point2d.along ax (Pixels.pixels (toFloat -window.width))
    in
    Polygon2d.translateBy (down y)
        (Polygon2d.singleLoop
            [ p1
            , p2
            , Point2d.translateBy (down 300) p2
            , Point2d.translateBy (down 300) p1
            ]
        )


axis : Window -> Axis2d Pixels coordinates
axis w =
    Axis2d.withDirection
        (Direction2d.degrees -26)
        (Point2d.pixels (vw w / 2) (vh w - 450))
