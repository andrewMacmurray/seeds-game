module Internal.Timeline exposing
    ( Timeline
    , animate
    , animation
    , keyframes
    , sequence
    , shiftBy
    , startAt
    , tween
    )

import Animation
import Animation.Keyframes as Keyframes
import Animation.Tween as Tween
import Html exposing (Attribute, Html)
import Html.Attributes as Attribute
import Internal.Animation
import Internal.Keyframes
import Internal.Position exposing (Position)
import Internal.Tween
import Internal.Utils
import Json.Encode as Encode



-- Sequence


type Timeline msg
    = Sequence (SequenceOptions msg)
    | Keyframes (KeyframesOptions msg)
    | Tween (TweenOptions msg)


type alias SequenceOptions msg =
    { animation : Animation.Options msg
    , timeline : List (Timeline msg)
    , position : Maybe Position
    }


type alias KeyframesOptions msg =
    { keyframes : Keyframes.Keyframes msg
    , element : Html msg
    }


type alias TweenOptions msg =
    { tween : Tween.Tween msg
    , element : Html msg
    }



-- Construct


sequence : List (Timeline msg) -> Animation.Options msg -> Timeline msg
sequence sequence_ animation_ =
    Sequence
        { timeline = sequence_
        , animation = animation_
        , position = Nothing
        }


animation : List (Timeline msg) -> Timeline msg
animation sequence_ =
    Sequence
        { timeline = sequence_
        , animation = Animation.options
        , position = Nothing
        }


keyframes : Keyframes.Keyframes msg -> Html msg -> Timeline msg
keyframes keyframes_ element =
    Keyframes
        { keyframes = keyframes_
        , element = element
        }


tween : Tween.Tween msg -> Html msg -> Timeline msg
tween tween_ element =
    Tween
        { tween = tween_
        , element = element
        }



-- Configure


startAt : Float -> Timeline msg -> Timeline msg
startAt =
    Internal.Position.time >> updatePosition


shiftBy : Float -> Timeline msg -> Timeline msg
shiftBy =
    Internal.Position.shiftBy >> updatePosition


updatePosition : Position -> Timeline msg -> Timeline msg
updatePosition position animation_ =
    case animation_ of
        Keyframes config ->
            Keyframes { config | keyframes = Internal.Keyframes.position_ position config.keyframes }

        Sequence config ->
            Sequence { config | position = Just position }

        Tween config ->
            Tween { config | tween = Internal.Tween.position_ position config.tween }



-- Animate


animate : Timeline msg -> Html msg
animate animation_ =
    case animation_ of
        Keyframes config ->
            Keyframes.animate config.keyframes config.element

        Tween config ->
            Tween.animate config.tween config.element

        Sequence config ->
            Html.node "timeline-element"
                [ encodeAnimation config.animation, positionAttribute config ]
                (List.map animate config.timeline)


positionAttribute : SequenceOptions msg -> Attribute msg
positionAttribute config =
    config.position
        |> Maybe.map Internal.Position.attribute
        |> Maybe.withDefault Internal.Utils.emptyAttribute


encodeAnimation : Animation.Options msg -> Attribute msg
encodeAnimation =
    Internal.Animation.encode
        >> Encode.object
        >> animationAttribute


animationAttribute : Encode.Value -> Attribute msg
animationAttribute =
    Encode.encode 0 >> Attribute.attribute "animation"
