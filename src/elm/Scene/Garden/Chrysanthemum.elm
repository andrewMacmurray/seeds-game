module Scene.Garden.Chrysanthemum exposing
    ( flowers
    , hills
    )

import Element exposing (Element)
import Element.Backdrop.RollingHills as RollingHills
import Element.Flower.Arranged.Chrysanthemum as Chrysanthemum
import Geometry.Shape as Shape exposing (Shape)
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
    Chrysanthemum.bloomed
