module Scene.Garden.Sunflower exposing
    ( flowers
    , hills
    )

import Element exposing (Element)
import Element.Backdrop.SteepHills as SteepHills
import Geometry.Shape exposing (Shape)
import Scene.Garden.Sunflower.Flowers as Flowers
import Window exposing (Window)


hills : Window -> Shape
hills window =
    SteepHills.static
        { hills = 6
        , window = window
        , colors = SteepHills.green
        }


flowers : Element msg
flowers =
    Flowers.flowers
