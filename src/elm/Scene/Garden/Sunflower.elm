module Scene.Garden.Sunflower exposing (view)

import Element exposing (..)
import View.Flower.Sunflower as Sunflower


view =
    column [ width fill, height fill ]
        [ el [ centerX, centerY ] (html (Sunflower.animated 0))
        ]
