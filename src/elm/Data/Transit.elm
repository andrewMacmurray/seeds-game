module Data.Transit exposing (..)

-- Simple wrapper type to represent a value that will be transitioned (usually via CSS)


type Transit a
    = Stationary a
    | Transitioning a


map : (a -> b) -> Transit a -> Transit b
map f transit =
    case transit of
        Stationary a ->
            Stationary <| f a

        Transitioning a ->
            Transitioning <| f a


val : Transit a -> a
val transit =
    case transit of
        Stationary a ->
            a

        Transitioning a ->
            a


toStationary : Transit a -> Transit a
toStationary transit =
    case transit of
        Stationary a ->
            Stationary a

        Transitioning a ->
            Stationary a


toTransitioning : Transit a -> Transit a
toTransitioning transit =
    case transit of
        Stationary a ->
            Transitioning a

        Transitioning a ->
            Transitioning a


isTransitioning : Transit a -> Bool
isTransitioning transit =
    case transit of
        Transitioning _ ->
            True

        _ ->
            False
