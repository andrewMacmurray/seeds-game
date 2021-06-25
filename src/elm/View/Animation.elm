module View.Animation exposing (animations)

import Css.Animation exposing (frame, keyframes, opacity, transform)
import Css.Transform exposing (rotate, scale, translateX)
import Html exposing (Html)


animations : Html msg
animations =
    Css.Animation.embed
        [ fadeOut
        , fadeIn
        , heartbeat
        , heartBreakLeft
        , heartBreakRight
        ]


fadeIn =
    -- Menu / Summary
    keyframes "fade-in"
        [ frame 0 [ opacity 0 ]
        , frame 100 [ opacity 1 ]
        ]


fadeOut =
    -- Menu / TopBar
    keyframes "fade-out"
        [ frame 0 [ opacity 1 ]
        , frame 100 [ opacity 0 ]
        ]


heartbeat =
    keyframes "heartbeat"
        [ frame 0 [ toScale 1 ]
        , frame 50 [ toScale 1.15 ]
        , frame 100 [ toScale 1 ]
        ]


heartBreakLeft =
    keyframes "heart-break-left"
        [ frame 0
            [ transform [ translateX 0, rotate 0 ] ]
        , frame 100
            [ transform [ translateX -3, rotate -2 ] ]
        ]


heartBreakRight =
    keyframes "heart-break-right"
        [ frame 0
            [ transform [ translateX 0, rotate 0 ] ]
        , frame 100
            [ transform [ translateX 3, rotate 2 ] ]
        ]


toScale : Float -> Css.Animation.Property
toScale n =
    transform [ scale n ]
