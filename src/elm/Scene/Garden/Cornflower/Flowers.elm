module Scene.Garden.Cornflower.Flowers exposing (flowers)

import Element exposing (..)
import Element.Flower.Cornflower as Cornflower
import Element.Scale as Scale
import Scene.Garden.Cornflower.Sprites as Ladybird
import Simple.Animation as Animation


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
            (flower 215)
        , row [ height (px 75) ]
            [ el [ moveLeft 40 ] (flower 120)
            , el [ moveRight 40 ] (flower 120)
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
        (el
            [ rotate (degrees angle)
            , moveRight x
            , moveDown y
            ]
            (Ladybird.ladybird delay)
        )


flower : Int -> Element msg
flower size =
    el [ width (px size) ] (html Cornflower.static)
