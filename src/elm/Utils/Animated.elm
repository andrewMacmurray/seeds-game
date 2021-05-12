module Utils.Animated exposing (g)

import Simple.Animation exposing (Animation)
import Simple.Animation.Animated as Animated
import Svg exposing (Svg)
import Svg.Attributes


g : Animation -> List (Svg.Attribute msg) -> List (Svg msg) -> Svg msg
g =
    svg_ Svg.g


svg_ :
    (List (Svg.Attribute msg) -> List (Svg msg) -> Svg msg)
    -> Animation
    -> List (Svg.Attribute msg)
    -> List (Svg msg)
    -> Svg msg
svg_ =
    Animated.svg
        { class = Svg.Attributes.class
        }
