module View.Animation exposing (animations)

import Css.Animation exposing (frame, keyframes, opacity)
import Html exposing (Html)


animations : Html msg
animations =
    Css.Animation.embed
        [ fadeOut
        , fadeIn
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
