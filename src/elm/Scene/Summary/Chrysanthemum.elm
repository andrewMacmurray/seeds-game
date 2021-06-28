module Scene.Summary.Chrysanthemum exposing
    ( flowers
    , hills
    )

import Element exposing (..)
import Element.Backdrop.RollingHills as RollingHills
import Element.Flower.Arranged.Chrysanthemum as Chrysanthemum
import Geometry.Shape as Shape exposing (Shape)
import Svg exposing (Svg)
import Window exposing (Window)



-- Flowers


flowers : Element msg
flowers =
    Chrysanthemum.blooming
        { delay = 1000
        }



-- Hills


hills : Window -> Svg msg
hills window =
    Shape.fullScreen window (hills_ window)


hills_ : Window -> Shape
hills_ window =
    RollingHills.animated
        { window = window
        , delay = 800
        }
