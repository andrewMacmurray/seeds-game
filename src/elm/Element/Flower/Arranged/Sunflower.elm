module Element.Flower.Arranged.Sunflower exposing
    ( bloomed
    , blooming
    )

import Element exposing (..)
import Element.Flower.Sunflower as Sunflower
import Element.Scale as Scale
import Element.Sprite.Butterfly as Butterfly
import Simple.Animation as Animation exposing (Animation)
import Simple.Animation.Property as P
import Svg exposing (Svg)
import Utils.Animated as Animated
import Utils.Element as Element



-- Arranged Sunflower


type alias BloomingOptions =
    { delay : Animation.Millis
    }


type FlowersAnimation
    = Animated Animation.Millis
    | None


type alias Options_ =
    { animation : FlowersAnimation
    }



-- Bloomed


bloomed : Element msg
bloomed =
    arranged_
        { animation = None
        }



-- Blooming


blooming : BloomingOptions -> Element msg
blooming options =
    arranged_
        { animation = Animated options.delay
        }



-- Internal


arranged_ : Options_ -> Element msg
arranged_ options =
    column [ centerX, spacing -Scale.large ]
        [ el []
            (flower options
                { size = 200
                , delay = 0
                , restingButterfly = Just { x = 50, y = 80 }
                , hoveringButterfly = Just { x = 120, y = 10 }
                }
            )
        , row []
            [ el [ moveLeft 50 ]
                (flower options
                    { size = 100
                    , delay = 200
                    , restingButterfly = Just { x = 70, y = 65 }
                    , hoveringButterfly = Just { x = 0, y = 0 }
                    }
                )
            , el [ moveRight 50 ]
                (flower options
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


flower : Options_ -> FlowerOptions -> Element msg
flower options_ flower_ =
    el
        [ width (px flower_.size)
        , inFront (Element.showIfJust (restingButterfly options_ flower_) flower_.restingButterfly)
        , inFront (Element.showIfJust (hoveringButterfly options_ flower_) flower_.hoveringButterfly)
        ]
        (html (sunflower options_ flower_))


sunflower : Options_ -> FlowerOptions -> Svg msg
sunflower options_ flower_ =
    case options_.animation of
        Animated delay ->
            Sunflower.animated (delay + flower_.delay)

        None ->
            Sunflower.static


type alias Position =
    { x : Float
    , y : Float
    }


hoveringButterfly : Options_ -> FlowerOptions -> Position -> Element msg
hoveringButterfly options_ options position =
    Animated.el (fadeInButterfly options_ options)
        [ width (px 20)
        , alignLeft
        , alignTop
        , moveRight position.x
        , moveDown position.y
        ]
        (Butterfly.hovering { delay = options.delay })


restingButterfly : Options_ -> FlowerOptions -> Position -> Element msg
restingButterfly options_ options position =
    Animated.el (fadeInButterfly options_ options)
        [ width (px 20)
        , alignLeft
        , alignTop
        , moveRight position.x
        , moveDown position.y
        ]
        (Butterfly.resting { delay = options.delay })


fadeInButterfly : Options_ -> FlowerOptions -> Animation
fadeInButterfly options_ options =
    Animation.steps
        { startAt = [ P.opacity 0 ]
        , options = []
        }
        [ Animation.wait (butterflyDelay options_ options)
        , Animation.step 1000 [ P.opacity 1 ]
        ]


butterflyDelay : Options_ -> FlowerOptions -> Animation.Millis
butterflyDelay options_ flower_ =
    case options_.animation of
        Animated delay ->
            List.sum [ flower_.delay, delay, 1800 ]

        None ->
            flower_.delay
