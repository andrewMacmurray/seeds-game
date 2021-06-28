module Scene.Summary.Cornflower exposing
    ( flowers
    , hills
    )

import Element exposing (..)
import Element.Animations as Animations
import Element.Backdrop.RollingValley as RollingValley
import Element.Flower.Cornflower as Cornflower
import Element.Scale as Scale
import Geometry.Shape as Shape exposing (Shape)
import Scene.Garden.Cornflower.Sprites as Ladybird
import Simple.Animation as Animation exposing (Animation)
import Svg exposing (Svg)
import Utils.Animated as Animated
import Window exposing (Window)



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
    RollingValley.animated
        { window = window
        , delay = 0
        }
