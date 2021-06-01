module Pointer exposing
    ( Pointer
    , onPointerDown
    , onPointerMove
    , onPointerUp
    , origin
    )

import Html exposing (Attribute)
import Html.Events as Events
import Json.Decode as Json exposing (Decoder, field, float)


type alias Pointer =
    { x : Int
    , y : Int
    }


origin : Pointer
origin =
    { x = 0
    , y = 0
    }


onPointerUp : msg -> Attribute msg
onPointerUp msg =
    Events.on "pointerup" (Json.succeed msg)


onPointerDown : (Pointer -> msg) -> Attribute msg
onPointerDown msg =
    Events.stopPropagationOn "pointerdown" (Json.map alwaysStop (tagPosition msg))


onPointerMove : (Pointer -> msg) -> Attribute msg
onPointerMove msg =
    Events.stopPropagationOn "pointermove" (Json.map alwaysStop (tagPosition msg))


alwaysStop : a -> ( a, Bool )
alwaysStop x =
    ( x, True )


tagPosition : (Pointer -> msg) -> Decoder msg
tagPosition msg =
    pointerDecoder |> Json.andThen (Json.succeed << msg)


pointerDecoder : Decoder Pointer
pointerDecoder =
    Json.map2 Pointer
        (field "x" float |> Json.map round)
        (field "y" float |> Json.map round)
