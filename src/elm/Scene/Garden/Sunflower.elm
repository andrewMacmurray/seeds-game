module Scene.Garden.Sunflower exposing
    ( flowers
    , hills
    )

import Element exposing (Element)
import Element.Backdrop.SteepValley as SteepValley
import Geometry.Shape exposing (Shape)
import Scene.Garden.Sunflower.Flowers as Flowers
import Window exposing (Window)


hills : Window -> Shape
hills window =
    SteepValley.static { window = window }


flowers : Element msg
flowers =
    Flowers.flowers
