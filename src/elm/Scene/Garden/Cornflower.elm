module Scene.Garden.Cornflower exposing
    ( flowers
    , hills
    )

import Element exposing (Element)
import Geometry.Shape as Shape exposing (Shape)
import Scene.Garden.Cornflower.Flowers as Flowers
import Scene.Garden.Cornflower.Hills as Hills
import Window exposing (Window)


hills : Window -> Shape
hills =
    Hills.shape


flowers : Element msg
flowers =
    Flowers.flowers
