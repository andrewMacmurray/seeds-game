module Scene.Garden.Cornflower exposing
    ( flowers
    , hills
    )

import Element exposing (Element)
import Element.Backdrop.RollingValley as RollingValley
import Element.Flower.Arranged.Cornflower as Cornflower
import Geometry.Shape exposing (Shape)
import Window exposing (Window)


hills : Window -> Shape
hills window =
    RollingValley.static
        { window = window
        }


flowers : Element msg
flowers =
    Cornflower.bloomed
