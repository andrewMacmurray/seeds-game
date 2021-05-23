module Utils.Animated exposing (column, el, g, path)

import Element exposing (Element)
import Simple.Animation exposing (Animation)
import Simple.Animation.Animated as Animated
import Svg exposing (Svg)
import Svg.Attributes



-- Elm UI


el : Animation -> List (Element.Attribute msg) -> Element msg -> Element msg
el =
    ui_ Element.el


column : Animation -> List (Element.Attribute msg) -> List (Element msg) -> Element msg
column =
    ui_ Element.column


ui_ :
    (List (Element.Attribute msg) -> children -> Element msg)
    -> Animation
    -> List (Element.Attribute msg)
    -> children
    -> Element msg
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
