module Config.Animations exposing (animations)

import Css.Animation as Animation exposing (frame, keyframes, opacity, transform)
import Css.Transform exposing (rotateZ, scale, translateX, translateY)
import Html exposing (Html)


animations : Html msg
animations =
    Animation.embed
        [ fadeOut
        , fadeIn
        , fadeSlideDown
        , slideDownScaleOut
        , exitDown
        , hover
        , bulgeFade
        , bulge
        , bulgeElastic
        , bulgeElasticBig
        , bulgeSmall
        , heartbeat
        , heartBreakLeft
        , heartBreakRight
        ]


fadeIn =
    keyframes "fade-in"
        [ frame 0 [ opacity 0 ]
        , frame 100 [ opacity 1 ]
        ]


fadeOut =
    keyframes "fade-out"
        [ frame 0 [ opacity 1 ]
        , frame 100 [ opacity 0 ]
        ]


fadeSlideDown =
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


slideDownScaleOut =
    keyframes "slide-down-scale-out"
        [ frame 0
            [ opacity 1, transform [ scale 1, translateY 0 ] ]
        , frame 50
            [ opacity 1, transform [ scale 1, translateY 40 ] ]
        , frame 60
            [ opacity 1, transform [ scale 1.1, translateY 40 ] ]
        , frame 100
            [ opacity 0, transform [ scale 0, translateY 40 ] ]
        ]


exitDown =
    keyframes "exit-down"
        [ frame 0
            [ opacity 1, toY 0 ]
        , frame 100
            [ opacity 0, toY 300 ]
        ]


hover =
    keyframes "hover"
        [ frame 0 [ toY 0 ]
        , frame 50 [ toY -5 ]
        , frame 100 [ toY 0 ]
        ]


bulgeFade =
    keyframes "bulge-fade"
        [ frame 0
            [ opacity 1, toScale 1 ]
        , frame 100
            [ opacity 0, toScale 2.5 ]
        ]


bulge =
    keyframes "bulge"
        [ frame 0
            [ toScale 0.5 ]
        , frame 50
            [ toScale 1.3 ]
        , frame 100
            [ toScale 1 ]
        ]


bulgeElastic =
    keyframes "bulge-elastic"
        [ frame 0
            [ opacity 0, toScale 0 ]
        , frame 50
            [ opacity 0.4, toScale 1.3 ]
        , frame 75
            [ opacity 0.7, toScale 0.9 ]
        , frame 100
            [ opacity 1, toScale 1 ]
        ]


bulgeElasticBig =
    keyframes "bulge-elastic-big"
        [ frame 0
            [ opacity 0, toScale 0.3 ]
        , frame 20
            [ opacity 1, toScale 1.3 ]
        , frame 40
            [ opacity 1, toScale 0.8 ]
        , frame 60
            [ opacity 1, toScale 1.1 ]
        , frame 80
            [ opacity 1, toScale 0.9 ]
        , frame 100
            [ opacity 1, toScale 1 ]
        ]


bulgeSmall =
    keyframes "bulge-small"
        [ frame 0
            [ opacity 0, toScale 0.5 ]
        , frame 50
            [ opacity 1, toScale 1.1 ]
        , frame 100
            [ opacity 1, toScale 1 ]
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
            [ transform [ translateX 0, rotateZ 0 ] ]
        , frame 100
            [ transform [ translateX -3, rotateZ -2 ] ]
        ]


heartBreakRight =
    keyframes "heart-break-right"
        [ frame 0
            [ transform [ translateX 0, rotateZ 0 ] ]
        , frame 100
            [ transform [ translateX 3, rotateZ 2 ] ]
        ]


toScale : Float -> Animation.Property
toScale n =
    transform [ scale n ]


toY : Float -> Animation.Property
toY n =
    transform [ translateY n ]
