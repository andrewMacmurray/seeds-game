module Helpers.Html exposing (..)

import Html exposing (Attribute)
import Html.Attributes exposing (property)
import Json.Encode exposing (string)
import Model exposing (Msg)


emptyProperty : Attribute Msg
emptyProperty =
    property "" <| string ""
