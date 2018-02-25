module Helpers.Html exposing (..)

import Html exposing (Attribute)
import Html.Attributes exposing (property)
import Html.Events exposing (onWithOptions)
import Json.Encode exposing (string)
import Json.Decode exposing (succeed)


onMouseDownPreventDefault : msg -> Attribute msg
onMouseDownPreventDefault msg =
    onWithOptions "mousedown" preventDefault (succeed msg)


preventDefault : Html.Events.Options
preventDefault =
    { stopPropagation = False
    , preventDefault = True
    }


emptyProperty : Attribute msg
emptyProperty =
    property "" <| string ""
