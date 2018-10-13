module Data.Pointer exposing
    ( Pointer
    , onPointerDown
    , onPointerMove
    , onPointerUp
    )

import Html exposing (Attribute, Html, node)
import Html.Attributes exposing (property)
import Html.Events exposing (on, stopPropagationOn)
import Json.Decode as Json exposing (Decoder, field, float)
import Json.Encode exposing (string)


type alias Pointer =
    { x : Int
    , y : Int
    }


onPointerUp : msg -> Attribute msg
onPointerUp msg =
    on "pointerup" <| Json.succeed msg


onPointerDown : (Pointer -> msg) -> Attribute msg
onPointerDown msg =
    stopPropagationOn "pointerdown" <| Json.map alwaysStop (tagPosition msg)


onPointerMove : (Pointer -> msg) -> Attribute msg
onPointerMove msg =
    stopPropagationOn "pointermove" <| Json.map alwaysStop (tagPosition msg)


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
