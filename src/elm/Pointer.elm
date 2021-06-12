module Pointer exposing
    ( Pointer
    , onPointerUp
    )

import Html exposing (Attribute)
import Html.Events as Events
import Json.Decode as Json


type alias Pointer =
    { x : Int
    , y : Int
    }


onPointerUp : msg -> Attribute msg
onPointerUp msg =
    Events.on "pointerup" (Json.succeed msg)
