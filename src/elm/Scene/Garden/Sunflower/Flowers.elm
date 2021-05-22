module Scene.Garden.Sunflower.Flowers exposing (flowers)

import Element exposing (..)
import Scene.Garden.Sunflower.Sprites as Butterfly
import Simple.Animation as Animation exposing (Animation)
import Utils.Element as Element
import View.Flower.Sunflower as Sunflower


flowers : Element msg
flowers =
    row []
        [ el [ moveDown 50, moveRight 50 ]
            (flower
                { size = 100
                , delay = 200
                , restingButterfly = Just { x = 70, y = 65 }
                , hoveringButterfly = Just { x = 0, y = 0 }
                }
            )
        , el [ moveUp 20 ]
            (flower
                { size = 200
                , delay = 0
                , restingButterfly = Just { x = 50, y = 80 }
                , hoveringButterfly = Just { x = 120, y = 10 }
                }
            )
        , el [ moveDown 50, moveLeft 50 ]
            (flower
                { size = 100
                , delay = 400
                , restingButterfly = Nothing
                , hoveringButterfly = Just { x = 75, y = 0 }
                }
            )
        ]


type alias Options =
    { size : Int
    , delay : Animation.Millis
    , restingButterfly : Maybe Position
    , hoveringButterfly : Maybe Position
    }


flower : Options -> Element msg
flower options =
    el
        [ width (px options.size)
        , inFront (Element.maybe (restingButterfly options) options.restingButterfly)
        , inFront (Element.maybe (hoveringButterfly options) options.hoveringButterfly)
        ]
        (html Sunflower.static)


type alias Position =
    { x : Float
    , y : Float
    }


hoveringButterfly : Options -> Position -> Element msg
hoveringButterfly options position =
    el
        [ width (px 20)
        , alignLeft
        , alignTop
        , moveRight position.x
        , moveDown position.y
        ]
        (Butterfly.hovering options.delay)


restingButterfly : Options -> Position -> Element msg
restingButterfly options position =
    el
        [ width (px 20)
        , alignLeft
        , alignTop
        , moveRight position.x
        , moveDown position.y
        ]
        (Butterfly.resting options.delay)
