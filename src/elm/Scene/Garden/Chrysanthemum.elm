module Scene.Garden.Chrysanthemum exposing (flowers, hills)

import Element exposing (Element)
import Geometry.Shape exposing (Shape)
import Scene.Garden.Chrysanthemum.Flowers as Flowers
import Scene.Garden.Chrysanthemum.Hills as Hills
import Window exposing (Window)


hills : Window -> Shape
hills =
    Hills.shape


flowers : Element msg
flowers =
    Flowers.flowers
