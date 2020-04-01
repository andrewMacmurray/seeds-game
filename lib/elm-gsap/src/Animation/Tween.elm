module Animation.Tween exposing
    ( Tween
    , from, to, fromTo
    , animate
    )

{-|


# Tween

@docs Tween


# Build

@docs from, to, fromTo


# Animate

@docs animate

-}

import Animation exposing (Options)
import Animation.Property exposing (Property)
import Html exposing (Html)
import Internal.Tween



-- Tween


{-| -}
type alias Tween msg =
    Internal.Tween.Tween msg



-- Construct


{-| -}
fromTo : ( List Property, List Property ) -> Options msg -> Tween msg
fromTo =
    Internal.Tween.fromTo


{-| -}
to : List Property -> Options msg -> Tween msg
to =
    Internal.Tween.to


{-| -}
from : List Property -> Options msg -> Tween msg
from =
    Internal.Tween.from



-- Animate


{-| -}
animate : Tween msg -> Html msg -> Html msg
animate =
    Internal.Tween.animate
