module Scene.Garden.Sunflower exposing
    ( flowers
    , hills
    )

import Element exposing (Element)
import Element.Backdrop.SteepValley as SteepValley
import Element.Flower.Arranged.Sunflower as Sunflower
import Geometry.Shape exposing (Shape)
import Window exposing (Window)


hills : Window -> Shape
hills window =
    SteepValley.static
        { window = window
        }


flowers : Element msg
flowers =
    Sunflower.bloomed
