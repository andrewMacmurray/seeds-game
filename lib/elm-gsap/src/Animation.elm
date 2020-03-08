module Animation exposing
    ( Options
    , options
    , infinite, repeat, repeatDelay, ease, delay, yoyo, duration, target
    , onStart, onComplete, onRepeat
    )

{-| Base Animation configuration


# Animation Options

@docs Options


# Build

@docs options


# Configure

@docs infinite, repeat, repeatDelay, ease, delay, yoyo, duration, target


# Events

@docs onStart, onComplete, onRepeat

-}

import Animation.Ease exposing (Ease)
import Internal.Animation



-- Animation


{-| -}
type alias Options msg =
    Internal.Animation.Options msg


{-| -}
options : Options msg
options =
    Internal.Animation.options



-- Configure


{-| -}
infinite : Options msg -> Options msg
infinite =
    Internal.Animation.infinite


{-| -}
repeat : Int -> Options msg -> Options msg
repeat =
    Internal.Animation.repeat


{-| -}
duration : Float -> Options msg -> Options msg
duration =
    Internal.Animation.duration


{-| -}
repeatDelay : Float -> Options msg -> Options msg
repeatDelay =
    Internal.Animation.repeatDelay


{-| -}
delay : Float -> Options msg -> Options msg
delay =
    Internal.Animation.delay


{-| -}
ease : Ease -> Options msg -> Options msg
ease =
    Internal.Animation.ease


{-| -}
yoyo : Options msg -> Options msg
yoyo =
    Internal.Animation.yoyo



-- Target


{-| -}
target : String -> Options msg -> Options msg
target =
    Internal.Animation.target



-- Events


{-| -}
onComplete : msg -> Options msg -> Options msg
onComplete =
    Internal.Animation.onComplete


{-| -}
onStart : msg -> Options msg -> Options msg
onStart =
    Internal.Animation.onStart


{-| -}
onRepeat : msg -> Options msg -> Options msg
onRepeat =
    Internal.Animation.onRepeat
