module Helpers.Html exposing (..)

import Html exposing (Attribute, Html, node)
import Html.Attributes exposing (property)
import Html.Events exposing (on, onWithOptions)
import Json.Decode as Json exposing (Decoder, field, float)
import Json.Encode exposing (string)
import Scenes.Level.Types exposing (Position)


embeddedStyle : String -> Html msg
embeddedStyle styleStr =
    node "style" [ property "textContent" <| string styleStr ] []


onPointerUp : msg -> Attribute msg
onPointerUp msg =
    on "pointerup" <| Json.succeed msg


onPointerDownPosition : (Position -> msg) -> Attribute msg
onPointerDownPosition =
    onWithOptions "pointerdown" preventDefault << tagPosition


onPointerMovePosition : (Position -> msg) -> Attribute msg
onPointerMovePosition =
    onWithOptions "pointermove" preventDefault << tagPosition


tagPosition : (Position -> msg) -> Decoder msg
tagPosition msg =
    positionDecoder |> Json.andThen (Json.succeed << msg)


positionDecoder : Decoder Position
positionDecoder =
    Json.map2 Position
        (field "x" float |> Json.map round)
        (field "y" float |> Json.map round)


preventDefault : Html.Events.Options
preventDefault =
    { stopPropagation = False
    , preventDefault = True
    }


emptyProperty : Attribute msg
emptyProperty =
    property "" <| string ""
