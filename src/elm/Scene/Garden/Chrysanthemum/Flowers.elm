module Scene.Garden.Chrysanthemum.Flowers exposing (flowers)

import Element exposing (..)
import Element.Flower.Chrysanthemum as Chrysanthemum
import Element.Sprite.Bee as Bee
import Simple.Animation as Animation


flowers : Element msg
flowers =
    row []
        [ el
            [ moveDown 25
            , moveRight 0
            , bee { x = 0, y = -16, delay = 1600 }
            ]
            (flower 75)
        , el
            [ moveUp 45
            , bee { x = 0, y = 15, delay = 0 }
            , bee { x = -25, y = -5, delay = 500 }
            , bee { x = 25, y = -25, delay = 700 }
            ]
            (flower 125)
        , el
            [ moveDown 25
            , moveLeft 0
            , bee { x = 0, y = -5, delay = 1200 }
            ]
            (flower 75)
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
            (Bee.sprite { delay = options.delay })
        )


flower : Int -> Element msg
flower size =
    el [ width (px size) ] (html Chrysanthemum.static)
