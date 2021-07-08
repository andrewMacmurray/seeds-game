module Utils.Animation.Property exposing (fill)

import Element exposing (Color)
import Simple.Animation.Property as P
import Utils.Color as Color


fill : Color -> P.Property
fill color =
    P.property "fill" (Color.toString color)
