module Scene.Summary.Cornflower exposing
    ( flowers
    , hills
    )

import Element exposing (..)
import Element.Backdrop.RollingValley as RollingValley
import Element.Flower.Arranged.Cornflower as Conflower
import Geometry.Shape as Shape exposing (Shape)
import Svg exposing (Svg)
import Window exposing (Window)



-- Flowers


flowers : Element msg
flowers =
    Conflower.blooming
        { delay = 1300
        }



-- Hills


hills : Window -> Svg msg
hills window =
    Shape.fullScreen window (hills_ window)


hills_ : Window -> Shape
hills_ window =
    RollingValley.animated
        { window = window
        , delay = 0
        }
