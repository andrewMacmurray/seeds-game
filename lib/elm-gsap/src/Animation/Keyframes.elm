module Animation.Keyframes exposing
    ( Keyframes, Frame
    , frames, animation, frame
    , animate
    )

{-|


# Keyframes

@docs Keyframes, Frame


# Build

@docs frames, animation, frame


# Animate

@docs animate

-}

import Animation exposing (Options)
import Animation.Property exposing (Property)
import Html exposing (Attribute, Html)
import Internal.Keyframes



-- Keyframes


{-| -}
type alias Keyframes msg =
    Internal.Keyframes.Keyframes msg


{-| -}
type alias Frame =
    Internal.Keyframes.Frame



-- Construct


{-| -}
frames : List Frame -> Options msg -> Keyframes msg
frames =
    Internal.Keyframes.frames


{-| -}
animation : List Frame -> Keyframes msg
animation =
    Internal.Keyframes.animation


{-| -}
frame : List Property -> Frame
frame =
    Internal.Keyframes.frame



-- Animate


{-| -}
animate : Keyframes msg -> Html msg -> Html msg
animate =
    Internal.Keyframes.animate
