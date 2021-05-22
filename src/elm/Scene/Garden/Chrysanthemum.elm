module Scene.Garden.Chrysanthemum exposing (flowers, hills)

import Element exposing (Element)
import Scene.Garden.Chrysanthemum.Flowers as Flowers
import Scene.Garden.Chrysanthemum.Hills as Hills
import Scene.Garden.Shape exposing (Shape)
import Window exposing (Window)


hills : Window -> Shape
hills =
    Hills.shape


flowers : Element msg
flowers =
    Flowers.flowers
