module Helpers.Html exposing (..)

import Html exposing (Attribute)
import Html.Attributes exposing (property)
import Json.Encode exposing (string)
import Scenes.Level.Model exposing (..)


emptyProperty : Attribute Msg
emptyProperty =
    property "" <| string ""
