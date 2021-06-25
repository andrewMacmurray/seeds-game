module Element.Backdrop.SteepHills exposing
    ( Colors
    , animated
    , green
    , shape
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
import Svg exposing (Svg)
import Utils.Geometry exposing (down)
import Window exposing (Window, vh, vw)



-- Hills


type alias AnimatedOptions =
    { window : Window
    , hills : Int
    , delay : Animation.Millis
    , colors : Colors
    }


type alias Colors =
    { one : Colors_
    , two : Colors_
    , three : Colors_
    }


type alias Colors_ =
    ( Color, Color )



-- Colors


green : Colors
green =
    { one = ( Palette.green8, Palette.green3 )
    , two = ( Palette.green4, Palette.green2 )
    , three = ( Palette.green1, Palette.green6 )
    }



-- View


animated : AnimatedOptions -> Svg msg
animated options =
    Shape.window options.window [] (shape options)


shape : AnimatedOptions -> Shape
shape options =
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


toHillPair : AnimatedOptions -> HillConfig -> List Shape
toHillPair options config =
    [ animateHill options
        config
        (hill
            { offset = config.offset
            , color = config.right
            }
            options.window
        )
    , animateHill options
        config
        (mirrored
            { offset = config.offset
            , color = config.left
            }
            options.window
        )
    ]



-- Animate


animateHill : AnimatedOptions -> HillConfig -> Shape -> Shape
animateHill options =
    fadeIn options >> Shape.animate


fadeIn : AnimatedOptions -> HillConfig -> Animation
fadeIn options config =
    Animations.fadeIn 500
        [ Animation.delay (fadeHillDelay options config)
        ]


fadeHillDelay : AnimatedOptions -> HillConfig -> Animation.Millis
fadeHillDelay options config =
    options.delay + (config.order * 150)



-- Colors


cycleColors : AnimatedOptions -> Int -> ( Color, Color )
cycleColors options i =
    case modBy 3 i of
        0 ->
            options.colors.one

        1 ->
            options.colors.two

        _ ->
            options.colors.three



-- Shape


mirrored : { offset : Float, color : Color } -> Window -> Shape
mirrored options window =
    Shape.mirror (hill options window)


hill : { offset : Float, color : Element.Color } -> Window -> Shape
hill { offset, color } window =
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
