module Scene.Summary.Chrysanthemum exposing
    ( flowers
    , hills
    , hills_
    )

import Element exposing (..)
import Element.Backdrop.RollingHills as RollingHills
import Element.Flower.Chrysanthemum as Chrysanthemum
import Element.Scale as Scale exposing (edges)
import Element.Sprite.Bee as Bee
import Geometry.Shape as Shape exposing (Shape)
import Simple.Animation as Animation
import Svg exposing (Svg)
import Window exposing (Window)



-- Flowers


flowers : Element msg
flowers =
    column
        [ centerX
        , spacing Scale.small
        , paddingEach { edges | bottom = Scale.medium }
        ]
        [ el
            [ centerX
            , bee { x = 0, y = 15, delay = 0 }
            , bee { x = -25, y = -5, delay = 500 }
            , bee { x = 25, y = -25, delay = 700 }
            ]
            (flower { size = 125, delay = 0 })
        , row
            [ centerX
            , spacing (Scale.extraLarge + Scale.large)
            ]
            [ el
                [ bee { x = 0, y = -16, delay = 1600 }
                ]
                (flower { size = 75, delay = 300 })
            , el
                [ bee { x = 0, y = -5, delay = 1200 }
                , alignRight
                ]
                (flower { size = 75, delay = 600 })
            ]
        ]


type alias BeeOptions =
    { x : Float
    , y : Float
    , delay : Animation.Millis
    }


bee : BeeOptions -> Attribute msg
bee options =
    inFront
        (el
            [ centerX
            , centerY
            , moveRight options.x
            , moveDown options.y
            ]
            (Bee.sprite { delay = options.delay + 3000 })
        )


type alias FlowerOptions =
    { size : Int
    , delay : Animation.Millis
    }


flower : FlowerOptions -> Element msg
flower options =
    el [ width (px options.size) ] (html (Chrysanthemum.animated (1000 + options.delay)))



-- Hills


hills : Window -> Svg msg
hills window =
    Shape.fullScreen window (hills_ window)


hills_ : Window -> Shape
hills_ window =
    RollingHills.animated
        { window = window
        , delay = 800
        }
