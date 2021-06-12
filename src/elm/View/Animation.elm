module View.Animation exposing (animations)

import Css.Animation exposing (frame, keyframes, opacity, transform)
import Css.Transform exposing (rotate, scale, translateX, translateY)
import Html exposing (Html)


animations : Html msg
animations =
    Css.Animation.embed
        [ fadeOut
        , fadeIn
        , fadeSlideDown
        , shake
        , bulgeFade
        , bulge
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


fadeSlideDown =
    -- Summary
    let
        offsetPerFrame =
            30 / 100
    in
    keyframes "fade-slide-down"
        [ frame 0
            [ opacity 1, toY 0 ]
        , frame 60
            [ opacity 1, toY <| offsetPerFrame * 60 ]
        , frame 100
            [ opacity 0, toY <| offsetPerFrame * 100 ]
        ]


shake =
    -- Summary
    keyframes "shake"
        [ frame 10 [ toX -1 ]
        , frame 20 [ toX 1 ]
        , frame 30 [ toX -1 ]
        , frame 40 [ toX 1 ]
        , frame 50 [ toX -1 ]
        , frame 60 [ toX 1 ]
        , frame 70 [ toX -1 ]
        , frame 80 [ toX 1 ]
        , frame 90 [ toX -1 ]
        ]


bulgeFade =
    -- Summary
    keyframes "bulge-fade"
        [ frame 0
            [ opacity 1, toScale 1 ]
        , frame 100
            [ opacity 0, toScale 2.5 ]
        ]


bulge =
    -- TopBar
    keyframes "bulge"
        [ frame 0
            [ toScale 0.5 ]
        , frame 50
            [ toScale 1.3 ]
        , frame 100
            [ toScale 1 ]
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


toY : Float -> Css.Animation.Property
toY n =
    transform [ translateY n ]


toX : Float -> Css.Animation.Property
toX n =
    transform [ translateX n ]
