module Scene.Garden.Sunflower exposing
    ( flowers
    , hills
    )

import Element exposing (Element)
import Scene.Garden.Shape exposing (Shape)
import Scene.Garden.Sunflower.Flowers as Flowers
import Scene.Garden.Sunflower.Hills as Hills
import Window exposing (Window)


hills : Window -> Shape
hills =
    Hills.shape


flowers : Element msg
flowers =
    Flowers.flowers
