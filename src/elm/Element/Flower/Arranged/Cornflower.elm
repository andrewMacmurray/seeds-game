module Element.Flower.Arranged.Cornflower exposing
    ( bloomed
    , blooming
    )

import Element exposing (..)
import Element.Animations as Animations
import Element.Flower.Cornflower as Cornflower
import Element.Scale as Scale
import Element.Sprite.Ladybird as Ladybird
import Simple.Animation as Animation exposing (Animation)
import Svg exposing (Svg)
import Utils.Animated as Animated



-- Arranged Cornflower


type alias BloomingOptions =
    { delay : Animation.Millis
    }


type FlowersAnimation
    = Animated Animation.Millis
    | None


type alias Options_ =
    { animation : FlowersAnimation
    }



-- View


blooming : BloomingOptions -> Element msg
blooming options =
    arranged_
        { animation = Animated options.delay
        }


bloomed : Element msg
bloomed =
    arranged_
        { animation = None
        }



-- Internal


arranged_ options =
    column
        [ centerX
        , spacing -Scale.extraLarge
        ]
        [ el
            [ moveRight 10
            , ladybird options { angle = 35, x = 35, y = 30, delay = 0 }
            , ladybird options { angle = 90, x = 120, y = 190, delay = 1300 }
            , ladybird options { angle = 155, x = 210, y = 90, delay = 600 }
            ]
            (flower options { size = 215, delay = 0 })
        , row []
            [ el [ moveLeft 40 ] (flower options { size = 120, delay = 300 })
            , el [ moveRight 40 ] (flower options { size = 120, delay = 600 })
            ]
        ]


type alias Ladybird =
    { angle : Float
    , x : Float
    , y : Float
    , delay : Animation.Millis
    }


ladybird : Options_ -> Ladybird -> Attribute msg
ladybird options { angle, x, y, delay } =
    inFront
        (Animated.el (fadeLadybird options delay)
            [ rotate (degrees angle)
            , moveRight x
            , moveDown y
            ]
            (Ladybird.sprite { delay = delay })
        )


fadeLadybird : Options_ -> Animation.Millis -> Animation
fadeLadybird options delay =
    case options.animation of
        Animated delay_ ->
            Animations.fadeIn 500
                [ Animation.delay (delay_ + 1500 + (delay // 2))
                ]

        None ->
            Animations.fadeIn 500
                [ Animation.delay (delay // 2)
                ]


type alias Flower =
    { size : Int
    , delay : Animation.Millis
    }


flower : Options_ -> Flower -> Element msg
flower options_ flower_ =
    el [ width (px flower_.size) ] (html (cornflower options_ flower_))


cornflower : Options_ -> Flower -> Svg msg
cornflower options_ flower_ =
    case options_.animation of
        Animated delay ->
            Cornflower.animated (delay + flower_.delay)

        None ->
            Cornflower.static
