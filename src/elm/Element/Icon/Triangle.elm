module Element.Icon.Triangle exposing (hovering)

import Element exposing (Element)
import Element.Icon as Icon
import Element.Palette as Palette
import Simple.Animation as Animation exposing (Animation)
import Simple.Animation.Property as P
import Svg
import Svg.Attributes exposing (..)
import Utils.Animated as Animated
import Utils.Svg as Svg



-- Hovering Triangle


hovering : List (Element.Attribute msg) -> Element msg
hovering attrs =
    Animated.el hover attrs icon


hover : Animation
hover =
    Animation.steps
        { startAt = [ P.y 0 ]
        , options = [ Animation.loop ]
        }
        [ Animation.step 750 [ P.y -5 ]
        , Animation.step 750 [ P.y 0 ]
        ]



-- Icon


icon : Element msg
icon =
    Icon.el
        [ height "18"
        , width "18"
        ]
        [ Svg.path
            [ d "M9 18l9-18H0z"
            , Svg.fill_ Palette.lightGold
            , fillRule "evenodd"
            ]
            []
        ]
