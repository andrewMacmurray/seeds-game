module Helpers.Html exposing (..)

import Html exposing (Attribute)
import Html.Attributes exposing (property)
import Html.Events exposing (onWithOptions)
import Json.Encode exposing (string)
import Json.Decode exposing (succeed)
import Scenes.Level.Model exposing (..)


onMouseDownPreventDefault : msg -> Attribute msg
onMouseDownPreventDefault msg =
    onWithOptions "mousedown" preventDefault (succeed msg)


preventDefault : Html.Events.Options
preventDefault =
    { stopPropagation = False
    , preventDefault = True
    }


emptyProperty : Attribute Msg
emptyProperty =
    property "" <| string ""
