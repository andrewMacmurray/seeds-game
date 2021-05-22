module Scene.Garden.Cornflower.Flowers exposing (flowers)

import Element exposing (..)
import View.Flower.Cornflower as Cornflower


flowers : Element msg
flowers =
    row []
        [ el
            [ moveDown 80
            , moveRight 60
            ]
            (flower 120)
        , el
            [ moveDown 10
            ]
            (flower 215)
        , el
            [ moveDown 80
            , moveLeft 60
            ]
            (flower 120)
        ]


flower : Int -> Element msg
flower size =
    el [ width (px size) ] (html Cornflower.static)
