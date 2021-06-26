module Scene.Garden.Chrysanthemum exposing (flowers, hills)

import Element exposing (Element)
import Element.Backdrop.RollingHills as RollingHills
import Geometry.Shape as Shape exposing (Shape)
import Scene.Garden.Chrysanthemum.Flowers as Flowers
import Window exposing (Window)


hills : Window -> Shape
hills window =
    Shape.moveDown 75
        (RollingHills.static
            { window = window
            }
        )


flowers : Element msg
flowers =
    Flowers.flowers
