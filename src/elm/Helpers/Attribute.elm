module Helpers.Attribute exposing (applyIf, empty)

import Html exposing (Attribute)
import Html.Attributes exposing (property)
import Json.Encode exposing (string)


empty : Attribute msg
empty =
    property "" <| string ""


applyIf : Bool -> Attribute msg -> Attribute msg
applyIf predicate attr =
    if predicate then
        attr

    else
        empty
