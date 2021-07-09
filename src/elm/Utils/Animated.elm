module Utils.Animated exposing (el, g, maybe, path)

import Element exposing (Element)
import Simple.Animation exposing (Animation)
import Simple.Animation.Animated as Animated
import Svg exposing (Svg)
import Svg.Attributes
import Utils.Svg as Svg



-- Elm UI


el : Animation -> List (Element.Attribute msg) -> Element msg -> Element msg
el =
    ui_ Element.el


maybe : Maybe Animation -> List (Element.Attribute msg) -> Element msg -> Element msg
maybe =
    Maybe.map el >> Maybe.withDefault Element.el


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
    svg_ Svg.g_


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
