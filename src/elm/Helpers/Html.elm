module Helpers.Html exposing (..)

import Html exposing (Attribute, Html, node)
import Html.Attributes exposing (property)
import Html.Events exposing (onWithOptions)
import Json.Decode exposing (succeed)
import Json.Encode exposing (string)


embeddedStyle : String -> Html msg
embeddedStyle styleStr =
    node "style" [ property "textContent" <| string styleStr ] []


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
