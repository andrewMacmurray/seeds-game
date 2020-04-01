module Animation.Ease exposing
    ( Ease
    , Eases, bounce, power1, power2, power3, power4, circ, quad, quart, quint, sine, expo, linear
    , Amplitude, Period, elastic, elasticWith
    , Overshoot, back, backWith
    , Direction, easeIn, easeOut, easeInOut
    )

{-| Animation Eases


# Ease

@docs Ease


# Eases

@docs Eases, bounce, power1, power2, power3, power4, circ, quad, quart, quint, sine, expo, linear


# Elastic

@docs Amplitude, Period, elastic, elasticWith


# Back

@docs Overshoot, back, backWith


# Direction

@docs Direction, easeIn, easeOut, easeInOut

-}

import Internal.Ease


{-| -}
type alias Ease =
    Internal.Ease.Ease


{-| -}
type alias Direction =
    Internal.Ease.Direction


{-| -}
type alias Eases =
    { easeIn : Ease
    , easeOut : Ease
    , easeInOut : Ease
    }


{-| -}
type alias Overshoot =
    Float


{-| -}
type alias Period =
    Float


{-| -}
type alias Amplitude =
    Float



-- Eases


{-| -}
elastic : Eases
elastic =
    toEases (Internal.Ease.Elastic Internal.Ease.Default)


{-| -}
back : Eases
back =
    toEases (Internal.Ease.Back Internal.Ease.Default)


{-| -}
elasticWith : Direction -> Amplitude -> Period -> Ease
elasticWith direction amplitude period =
    Internal.Ease.Elastic (Internal.Ease.Custom (Internal.Ease.ElasticConfig amplitude period)) direction


{-| -}
backWith : Direction -> Overshoot -> Ease
backWith direction overshoot =
    Internal.Ease.Back (Internal.Ease.Custom overshoot) direction


{-| -}
bounce : Eases
bounce =
    toEases Internal.Ease.Bounce


{-| -}
power1 : Eases
power1 =
    toEases Internal.Ease.Power1


{-| -}
power2 : Eases
power2 =
    toEases Internal.Ease.Power2


{-| -}
power3 : Eases
power3 =
    toEases Internal.Ease.Power3


{-| -}
power4 : Eases
power4 =
    toEases Internal.Ease.Power4


{-| -}
circ : Eases
circ =
    toEases Internal.Ease.Circ


{-| -}
quad : Eases
quad =
    toEases Internal.Ease.Quad


{-| -}
quart : Eases
quart =
    toEases Internal.Ease.Quart


{-| -}
quint : Eases
quint =
    toEases Internal.Ease.Quint


{-| -}
sine : Eases
sine =
    toEases Internal.Ease.Sine


{-| -}
expo : Eases
expo =
    toEases Internal.Ease.Expo


{-| -}
linear : Ease
linear =
    Internal.Ease.Linear



-- Directions


{-| -}
easeIn : Direction
easeIn =
    Internal.Ease.In


{-| -}
easeOut : Direction
easeOut =
    Internal.Ease.Out


{-| -}
easeInOut : Direction
easeInOut =
    Internal.Ease.InOut



-- Utils


toEases : (Direction -> Ease) -> Eases
toEases ease =
    { easeIn = ease Internal.Ease.In
    , easeOut = ease Internal.Ease.Out
    , easeInOut = ease Internal.Ease.InOut
    }
