module Internal.Utils exposing (emptyAttribute)

import Html exposing (Attribute)
import Html.Attributes exposing (property)
import Json.Encode exposing (string)


emptyAttribute : Attribute msg
emptyAttribute =
    property "" (string "")
