module Scene.Summary.Sunflower exposing
    ( flowers
    , hills
    )

import Element exposing (..)
import Element.Backdrop.SteepHills as SteepHills
import Element.Flower.Sunflower as Sunflower
import Element.Scale as Scale
import Geometry.Shape as Shape
import Scene.Garden.Sunflower.Sprites as Butterfly
import Simple.Animation as Animation exposing (Animation)
import Simple.Animation.Property as P
import Svg exposing (Svg)
import Utils.Animated as Animated
import Utils.Element as Element
import Window exposing (Window)



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
    Animated.el (fadeInButterfly options)
        [ width (px 20)
        , alignLeft
        , alignTop
        , moveRight position.x
        , moveDown position.y
        ]
        (Butterfly.hovering options.delay)


restingButterfly : FlowerOptions -> Position -> Element msg
restingButterfly options position =
    Animated.el (fadeInButterfly options)
        [ width (px 20)
        , alignLeft
        , alignTop
        , moveRight position.x
        , moveDown position.y
        ]
        (Butterfly.resting options.delay)


fadeInButterfly : FlowerOptions -> Animation
fadeInButterfly options =
    Animation.steps
        { startAt = [ P.opacity 0 ]
        , options = []
        }
        [ Animation.wait (butterflyDelay options)
        , Animation.step 1000 [ P.opacity 1 ]
        ]


butterflyDelay : FlowerOptions -> Animation.Millis
butterflyDelay options =
    List.sum
        [ options.delay
        , delays.hills
        , delays.sunflowers
        , 1800
        ]



-- Hills


hills : Window -> Svg msg
hills window =
    Shape.fullScreen window
        (SteepHills.animated
            { window = window
            , delay = delays.hills
            }
        )
