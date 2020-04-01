module Animation.Property exposing
    ( Property
    , duration, opacity, x, y, scale, rotation, ease, stagger
    , Origin(..), origin, percentOrigin
    )

{-|


# Property

@docs Property


# Properties

@docs duration, opacity, x, y, scale, rotation, ease, stagger


# Transform Origin

@docs Origin, origin, percentOrigin

-}

import Animation.Ease as Ease
import Internal.Property as Internal



-- Property


{-| -}
type alias Property =
    Internal.Property


{-| -}
type Origin
    = Bottom
    | Left
    | Top
    | Right
    | Center
    | TopRight
    | TopLeft
    | BottomRight
    | BottomLeft



-- Properties


{-| -}
duration : Float -> Property
duration =
    Internal.Duration


{-| -}
opacity : Float -> Property
opacity =
    Internal.Opacity


{-| -}
x : Float -> Property
x =
    Internal.X


{-| -}
y : Float -> Property
y =
    Internal.Y


{-| -}
scale : Float -> Property
scale =
    Internal.Scale


{-| -}
rotation : Float -> Property
rotation =
    Internal.Rotation


{-| -}
ease : Ease.Ease -> Property
ease =
    Internal.Ease


{-| -}
stagger : Float -> Property
stagger =
    Internal.Stagger


{-| -}
origin : Origin -> Property
origin =
    Internal.TransformOrigin << Internal.Origin << toInternalOrigin


{-| -}
percentOrigin : Float -> Float -> Property
percentOrigin p1 p2 =
    Internal.TransformOrigin (Internal.Percent p1 p2)



-- Helpers


toInternalOrigin : Origin -> Internal.Origin
toInternalOrigin d =
    case d of
        Top ->
            Internal.Top

        Bottom ->
            Internal.Bottom

        Left ->
            Internal.Left

        Right ->
            Internal.Right

        Center ->
            Internal.Center

        TopRight ->
            Internal.TopRight

        TopLeft ->
            Internal.TopLeft

        BottomRight ->
            Internal.BottomRight

        BottomLeft ->
            Internal.BottomLeft
