module Helpers.Attribute exposing (emptyProperty)

import Html exposing (Attribute)
import Html.Attributes exposing (property)
import Json.Encode exposing (string)


emptyProperty : Attribute msg
emptyProperty =
    property "" <| string ""
