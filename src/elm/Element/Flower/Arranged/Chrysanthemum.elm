module Element.Flower.Arranged.Chrysanthemum exposing
    ( bloomed
    , blooming
    )

import Element exposing (..)
import Element.Flower.Chrysanthemum as Chrysanthemum
import Element.Scale as Scale exposing (edges)
import Element.Sprite.Bee as Bee
import Simple.Animation as Animation
import Svg exposing (Svg)



-- Arranged Chrysanthemum


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


arranged_ : Options_ -> Element msg
arranged_ options =
    column
        [ centerX
        , spacing Scale.small
        , paddingEach { edges | bottom = Scale.medium }
        ]
        [ el
            [ centerX
            , bee options { x = 0, y = 15, delay = 0 }
            , bee options { x = -25, y = -5, delay = 500 }
            , bee options { x = 25, y = -25, delay = 700 }
            ]
            (flower options { size = 125, delay = 0 })
        , row
            [ centerX
            , spacing (Scale.extraLarge + Scale.large)
            ]
            [ el
                [ bee options { x = 0, y = -16, delay = 1600 }
                ]
                (flower options { size = 75, delay = 300 })
            , el
                [ bee options { x = 0, y = -5, delay = 1200 }
                , alignRight
                ]
                (flower options { size = 75, delay = 600 })
            ]
        ]


type alias BeeOptions =
    { x : Float
    , y : Float
    , delay : Animation.Millis
    }


bee : Options_ -> BeeOptions -> Attribute msg
bee options_ bee_ =
    inFront
        (el
            [ centerX
            , centerY
            , moveRight bee_.x
            , moveDown bee_.y
            ]
            (sprite options_ bee_)
        )


sprite : Options_ -> BeeOptions -> Element msg
sprite options_ bee_ =
    case options_.animation of
        Animated delay ->
            Bee.sprite { delay = bee_.delay + delay + 2000 }

        None ->
            Bee.sprite { delay = bee_.delay }


type alias FlowerOptions =
    { size : Int
    , delay : Animation.Millis
    }


flower : Options_ -> FlowerOptions -> Element msg
flower options_ flower_ =
    el [ width (px flower_.size) ] (html (chrysanthemum options_ flower_))


chrysanthemum : Options_ -> FlowerOptions -> Svg msg
chrysanthemum options_ flower_ =
    case options_.animation of
        Animated delay ->
            Chrysanthemum.animated (delay + flower_.delay)

        None ->
            Chrysanthemum.static
