module Utils.Attribute exposing (applyIf)

import Html exposing (Attribute)
import Html.Attributes exposing (class)


empty : Attribute msg
empty =
    class ""


applyIf : Bool -> Attribute msg -> Attribute msg
applyIf predicate attr =
    if predicate then
        attr

    else
        empty
