module Internal.Keyframes exposing
    ( Frame
    , Keyframes
    , animate
    , animation
    , frame
    , frames
    , position_
    )

import Animation
import Animation.Property exposing (Property)
import Html exposing (Attribute, Html)
import Html.Attributes as Attribute
import Internal.Animation
import Internal.Position as Position exposing (Position)
import Internal.Property
import Internal.Utils
import Json.Encode as Encode



-- Keyframes


type Keyframes msg
    = Animation (Config msg)


type alias Config msg =
    { animation : Animation.Options msg
    , keyframes : List Frame
    , position : Maybe Position
    }


type Frame
    = Frame (List Property)



-- Construct


frames : List Frame -> Animation.Options msg -> Keyframes msg
frames keyframes_ animation_ =
    Animation
        { animation = animation_
        , keyframes = keyframes_
        , position = Nothing
        }


animation : List Frame -> Keyframes msg
animation keyframes_ =
    Animation
        { animation = Animation.options
        , keyframes = keyframes_
        , position = Nothing
        }


frame : List Property -> Frame
frame =
    Frame



-- Configure


position_ : Position -> Keyframes msg -> Keyframes msg
position_ position (Animation config) =
    Animation { config | position = Just position }



-- Animate


animate : Keyframes msg -> Html msg -> Html msg
animate animation_ el =
    Html.node "keyframes-element"
        [ animationAttribute (encode animation_)
        , positionAttribute animation_
        ]
        [ el ]



-- Encode


positionAttribute : Keyframes msg -> Attribute msg
positionAttribute (Animation config) =
    config.position
        |> Maybe.map Position.attribute
        |> Maybe.withDefault Internal.Utils.emptyAttribute


animationAttribute : Encode.Value -> Attribute msg
animationAttribute =
    Encode.encode 0 >> Attribute.attribute "animation"


encode : Keyframes msg -> Encode.Value
encode (Animation config) =
    ( "keyframes", Encode.list encodeFrame config.keyframes )
        :: Internal.Animation.encode config.animation
        |> Encode.object


encodeFrame : Frame -> Encode.Value
encodeFrame (Frame properties) =
    Encode.object (List.map Internal.Property.encode properties)
