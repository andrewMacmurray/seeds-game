module Element.Touch exposing
    ( Point
    , onMove
    , onRelease
    , onStart_
    , origin
    )

import Element exposing (Attribute, htmlAttribute)
import Html
import Html.Events as Events
import Json.Decode as Json exposing (Decoder, field, float)



-- Touch Point


type alias Point =
    { x : Int
    , y : Int
    }



-- Origin


origin : Point
origin =
    { x = 0
    , y = 0
    }



-- Html Events


onStart_ : (Point -> msg) -> Html.Attribute msg
onStart_ msg =
    Events.stopPropagationOn "pointerdown" (Json.map alwaysStop (tagPosition msg))



-- Element Events


onRelease : msg -> Element.Attribute msg
onRelease msg =
    on "pointerup" (Json.succeed msg)


onMove : (Point -> msg) -> Element.Attribute msg
onMove msg =
    stopPropagationOn "pointermove" (Json.map alwaysStop (tagPosition msg))



-- Internal


on : String -> Decoder msg -> Element.Attribute msg
on e decoder =
    htmlAttribute (Events.on e decoder)


stopPropagationOn : String -> Decoder ( msg, Bool ) -> Element.Attribute msg
stopPropagationOn e decoder =
    htmlAttribute (Events.stopPropagationOn e decoder)


alwaysStop : a -> ( a, Bool )
alwaysStop x =
    ( x, True )


tagPosition : (Point -> msg) -> Decoder msg
tagPosition msg =
    pointerDecoder |> Json.andThen (Json.succeed << msg)


pointerDecoder : Decoder Point
pointerDecoder =
    Json.map2 Point
        (field "x" float |> Json.map round)
        (field "y" float |> Json.map round)
