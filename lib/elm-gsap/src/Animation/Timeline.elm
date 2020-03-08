module Animation.Timeline exposing
    ( Timeline
    , sequence, animation, keyframes, tween
    , startAt, shiftBy
    , animate
    )

{-|


# Timeline

@docs Timeline


# Build

@docs sequence, animation, keyframes, tween


# Configure

@docs startAt, shiftBy


# Animate

@docs animate

-}

import Animation exposing (Options)
import Animation.Keyframes exposing (Keyframes)
import Animation.Tween exposing (Tween)
import Html exposing (Attribute, Html)
import Internal.Timeline



-- Sequence


{-| -}
type alias Timeline msg =
    Internal.Timeline.Timeline msg



-- Construct


{-| -}
sequence : List (Timeline msg) -> Options msg -> Timeline msg
sequence =
    Internal.Timeline.sequence


{-| -}
animation : List (Timeline msg) -> Timeline msg
animation =
    Internal.Timeline.animation


{-| -}
keyframes : Keyframes msg -> Html msg -> Timeline msg
keyframes =
    Internal.Timeline.keyframes


{-| -}
tween : Tween msg -> Html msg -> Timeline msg
tween =
    Internal.Timeline.tween



-- Configure


{-| -}
startAt : Float -> Timeline msg -> Timeline msg
startAt =
    Internal.Timeline.startAt


{-| -}
shiftBy : Float -> Timeline msg -> Timeline msg
shiftBy =
    Internal.Timeline.shiftBy



-- Animate


{-| -}
animate : Timeline msg -> Html msg
animate =
    Internal.Timeline.animate
