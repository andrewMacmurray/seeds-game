module Helpers.Attribute exposing (empty)

import Html exposing (Attribute)
import Html.Attributes exposing (property)
import Json.Encode exposing (string)


empty : Attribute msg
empty =
    property "" <| string ""
