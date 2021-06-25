module Scene.Summary.Sunflower exposing
    ( flowers
    , hills
    )

import Axis2d exposing (Axis2d)
import Direction2d
import Element exposing (..)
import Element.Animations as Animations
import Element.Flower.Sunflower as Sunflower
import Element.Palette as Palette
import Element.Scale as Scale
import Geometry.Shape as Shape exposing (Shape)
import Pixels exposing (Pixels)
import Point2d
import Polygon2d exposing (Polygon2d)
import Scene.Garden.Sunflower.Sprites as Butterfly
import Simple.Animation as Animation exposing (Animation)
import Simple.Animation.Property as P
import Svg exposing (Svg)
import Utils.Animated as Animated
import Utils.Element as Element
import Utils.Geometry exposing (down)
import Window exposing (Window, vh, vw)



-- Delays


type alias Delays =
    { sunflowers : Animation.Millis
    , hills : Animation.Millis
    }


delays : Delays
delays =
    { sunflowers = 500
    , hills = 300
    }



-- Flowers


flowers : Element msg
flowers =
    column [ centerX, spacing -Scale.large ]
        [ el []
            (flower
                { size = 200
                , delay = 0
                , restingButterfly = Just { x = 50, y = 80 }
                , hoveringButterfly = Just { x = 120, y = 10 }
                }
            )
        , row []
            [ el [ moveLeft 50 ]
                (flower
                    { size = 100
                    , delay = 200
                    , restingButterfly = Just { x = 70, y = 65 }
                    , hoveringButterfly = Just { x = 0, y = 0 }
                    }
                )
            , el [ moveRight 50 ]
                (flower
                    { size = 100
                    , delay = 400
                    , restingButterfly = Nothing
                    , hoveringButterfly = Just { x = 75, y = 0 }
                    }
                )
            ]
        ]


type alias FlowerOptions =
    { size : Int
    , delay : Animation.Millis
    , restingButterfly : Maybe Position
    , hoveringButterfly : Maybe Position
    }


flower : FlowerOptions -> Element msg
flower options =
    el
        [ width (px options.size)
        , inFront (Element.showIfJust (restingButterfly options) options.restingButterfly)
        , inFront (Element.showIfJust (hoveringButterfly options) options.hoveringButterfly)
        ]
        (html (Sunflower.animated (delays.sunflowers + options.delay)))


type alias Position =
    { x : Float
    , y : Float
    }


hoveringButterfly : FlowerOptions -> Position -> Element msg
hoveringButterfly options position =
    Animated.el fadeInButterfly
        [ width (px 20)
        , alignLeft
        , alignTop
        , moveRight position.x
        , moveDown position.y
        ]
        (Butterfly.hovering options.delay)


restingButterfly : FlowerOptions -> Position -> Element msg
restingButterfly options position =
    Animated.el fadeInButterfly
        [ width (px 20)
        , alignLeft
        , alignTop
        , moveRight position.x
        , moveDown position.y
        ]
        (Butterfly.resting options.delay)



-- Hills


hills : Window -> Svg msg
hills window =
    Shape.window window [] (hills_ window)


hills_ : Window -> Shape
hills_ window =
    List.range 0 maxHills
        |> List.map cycleHillColors
        |> List.indexedMap toHillConfig
        |> List.map (toHillPair window)
        |> List.concat
        |> List.reverse
        |> Shape.group
        |> Shape.moveUp 50


maxHills : number
maxHills =
    5


toHillPair : Window -> HillConfig -> List Shape
toHillPair window config =
    [ animateHill config
        (hill
            { offset = config.offset
            , color = config.right
            }
            window
        )
    , animateHill config
        (mirrored
            { offset = config.offset
            , color = config.left
            }
            window
        )
    ]


animateHill : HillConfig -> Shape -> Shape
animateHill =
    fadeIn >> Shape.animate


fadeIn : HillConfig -> Animation
fadeIn config =
    Animations.fadeIn 500
        [ Animation.delay (fadeHillDelay config.order)
        ]


fadeHillDelay : Int -> Animation.Millis
fadeHillDelay order =
    delays.hills + (order * 150)


fadeInButterfly : Animation
fadeInButterfly =
    Animation.steps
        { startAt = [ P.opacity 0 ]
        , options = []
        }
        [ Animation.wait (fadeHillDelay maxHills)
        , Animation.wait (delays.sunflowers + 1000)
        , Animation.step 1000 [ P.opacity 1 ]
        ]


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


cycleHillColors : Int -> ( Color, Color )
cycleHillColors i =
    case modBy 3 i of
        0 ->
            ( Palette.green8, Palette.green3 )

        1 ->
            ( Palette.green4, Palette.green2 )

        _ ->
            ( Palette.green1, Palette.green6 )


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
