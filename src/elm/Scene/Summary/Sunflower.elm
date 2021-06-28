module Scene.Summary.Sunflower exposing
    ( flowers
    , hills
    )

import Element exposing (..)
import Element.Backdrop.SteepValley as SteepValley
import Element.Flower.Arranged.Sunflower as Sunflower
import Geometry.Shape as Shape exposing (Shape)
import Simple.Animation as Animation
import Svg exposing (Svg)
import Window exposing (Window)



-- Delays


type alias Delays =
    { sunflowers : Animation.Millis
    , hills : Animation.Millis
    }


delays : Delays
delays =
    { sunflowers = 500
    , hills = 300
    }



-- Flowers


flowers : Element msg
flowers =
    Sunflower.blooming
        { delay = delays.hills + delays.sunflowers
        }



-- Hills


hills : Window -> Svg msg
hills window =
    Shape.fullScreen window (hills_ window)


hills_ : Window -> Shape
hills_ window =
    SteepValley.animated
        { window = window
        , delay = delays.hills
        }
