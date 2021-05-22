module Scene.Garden.Chrysanthemum.Flowers exposing (flowers)

import Element exposing (..)
import View.Flower.Chrysanthemum as Chrysanthemum


flowers : Element msg
flowers =
    row []
        [ el [ moveDown 25, moveRight 0 ]
            (flower
                { size = 75
                , delay = 200
                }
            )
        , el [ moveUp 45 ]
            (flower
                { size = 125
                , delay = 0
                }
            )
        , el [ moveDown 25, moveLeft 0 ]
            (flower
                { size = 75
                , delay = 400
                }
            )
        ]


flower options =
    el
        [ width (px options.size)
        ]
        (html Chrysanthemum.static)
