module Scene.Garden.Cornflower exposing
    ( flowers
    , hills
    )

import Element exposing (Element)
import Element.Backdrop.RollingValley as RollingValley
import Geometry.Shape exposing (Shape)
import Scene.Garden.Cornflower.Flowers as Flowers
import Window exposing (Window)


hills : Window -> Shape
hills window =
    RollingValley.static { window = window }


flowers : Element msg
flowers =
    Flowers.flowers
