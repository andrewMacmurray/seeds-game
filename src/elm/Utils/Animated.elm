module Utils.Animated exposing (el, g, path)

import Element
import Simple.Animation exposing (Animation)
import Simple.Animation.Animated as Animated
import Svg exposing (Svg)
import Svg.Attributes



-- Elm UI


el : Animation -> List (Element.Attribute msg) -> Element.Element msg -> Element.Element msg
el =
    ui_ Element.el


ui_ :
    (List (Element.Attribute msg) -> children -> Element.Element msg)
    -> Animation
    -> List (Element.Attribute msg)
    -> children
    -> Element.Element msg
ui_ =
    Animated.ui
        { html = Element.html
        , htmlAttribute = Element.htmlAttribute
        , behindContent = Element.behindContent
        }



-- Svg


g : Animation -> List (Svg.Attribute msg) -> List (Svg msg) -> Svg msg
g =
    svg_ Svg.g


path =
    svg_ Svg.path


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
