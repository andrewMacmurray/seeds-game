module Scene.Garden.Sunflower exposing
    ( flowers
    , hills
    )

import Element exposing (Element)
import Scene.Garden.Sunflower.Flowers as Flowers
import Scene.Garden.Sunflower.Hills as Hills
import Shape exposing (Shape)
import Window exposing (Window)


hills : Window -> Shape
hills =
    Hills.shape


flowers : Element msg
flowers =
    Flowers.flowers
