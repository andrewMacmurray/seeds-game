module Helpers.Html exposing
    ( embeddedStyle
    , emptyProperty
    )

import Html exposing (Attribute, Html, node)
import Html.Attributes exposing (property)
import Html.Events exposing (on, stopPropagationOn)
import Json.Decode as Json exposing (Decoder, field, float)
import Json.Encode exposing (string)


embeddedStyle : String -> Html msg
embeddedStyle styleStr =
    node "style" [ property "textContent" <| string styleStr ] []


emptyProperty : Attribute msg
emptyProperty =
    property "" <| string ""
