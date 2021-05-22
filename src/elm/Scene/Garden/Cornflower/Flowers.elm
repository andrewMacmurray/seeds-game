module Scene.Garden.Cornflower.Flowers exposing (flowers)

import Element exposing (..)
import Scene.Garden.Cornflower.Sprites as Ladybird
import View.Flower.Cornflower as Cornflower


flowers : Element msg
flowers =
    row []
        [ el
            [ moveDown 80
            , moveRight 70
            ]
            (flower 120)
        , el
            [ moveDown 10
            , ladybird { angle = 45, x = 15, y = 55, delay = 0 }
            , ladybird { angle = 90, x = 120, y = 180, delay = 1300 }
            , ladybird { angle = 135, x = 210, y = 90, delay = 600 }
            ]
            (flower 215)
        , el
            [ moveDown 80
            , moveLeft 70
            ]
            (flower 120)
        ]


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
