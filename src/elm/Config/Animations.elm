module Config.Animations exposing (..)

import Helpers.Css.Keyframes exposing (..)
import Html exposing (Html)


internalAnimations : Html msg
internalAnimations =
    embed
        [ bulge
        , bulgeFade
        , exitDown
        , fadeIn
        , fadeOut
        , heartBeat
        , heartBreakLeft
        , heartBreakRight
        ]


exitDown : KeyframesAnimation
exitDown =
    { name = "exit-down"
    , frames =
        map2 ( translateY, opacity )
            [ ( 0, ( 0, 1 ) )
            , ( 100, ( 300, 0 ) )
            ]
    }


bulgeFade : KeyframesAnimation
bulgeFade =
    { name = "bulge-fade"
    , frames =
        map2 ( scale, opacity )
            [ ( 0, ( 1, 1 ) )
            , ( 100, ( 2.5, 0 ) )
            ]
    }


bulge : KeyframesAnimation
bulge =
    { name = "bulge"
    , frames =
        map scale
            [ ( 0, 0.5 )
            , ( 50, 1.3 )
            , ( 100, 1 )
            ]
    }


fadeIn : KeyframesAnimation
fadeIn =
    { name = "fade-in"
    , frames =
        map opacity
            [ ( 0, 0 )
            , ( 100, 1 )
            ]
    }


fadeOut : KeyframesAnimation
fadeOut =
    { name = "fade-out"
    , frames =
        map opacity
            [ ( 0, 1 )
            , ( 100, 0 )
            ]
    }


heartBeat : KeyframesAnimation
heartBeat =
    { name = "heartbeat"
    , frames =
        map scale
            [ ( 0, 1 )
            , ( 50, 1.15 )
            , ( 100, 1 )
            ]
    }


heartBreakLeft : KeyframesAnimation
heartBreakLeft =
    { name = "heart-break-left"
    , frames =
        map2 ( translateX, rotateZ )
            [ ( 0, ( 0, 0 ) )
            , ( 100, ( -3, -2 ) )
            ]
    }


heartBreakRight : KeyframesAnimation
heartBreakRight =
    { name = "heart-break-right"
    , frames =
        map2 ( translateX, rotateZ )
            [ ( 0, ( 0, 0 ) )
            , ( 100, ( 3, 2 ) )
            ]
    }
