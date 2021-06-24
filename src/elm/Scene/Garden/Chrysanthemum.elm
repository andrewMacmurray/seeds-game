module Scene.Garden.Chrysanthemum exposing (flowers, hills)

import Element exposing (Element)
import Geometry.Shape as Shape exposing (Shape)
import Scene.Garden.Chrysanthemum.Flowers as Flowers
import Scene.Summary.Chrysanthemum as Hills
import Window exposing (Window)


hills : Window -> Shape
hills window =
    Hills.shape window
        |> Shape.moveDown 75


flowers : Element msg
flowers =
    Flowers.flowers
