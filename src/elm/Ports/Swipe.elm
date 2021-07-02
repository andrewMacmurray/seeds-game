port module Ports.Swipe exposing (onRight)


onRight : msg -> Sub msg
onRight msg =
    onRightSwipe (always msg)


port onRightSwipe : (() -> msg) -> Sub msg
