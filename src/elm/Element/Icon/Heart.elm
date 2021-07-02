module Element.Icon.Heart exposing
    ( beating
    , breaking
    , broken
    , static
    )

import Element exposing (..)
import Element.Icon as Icon
import Element.Palette as Palette
import Simple.Animation as Animation exposing (Animation)
import Simple.Animation.Property as P
import Svg
import Svg.Attributes exposing (..)
import Utils.Animated as Animated
import Utils.Style as Style
import Utils.Svg as Svg



-- Static


static : Element msg
static =
    Icon.el
        [ Svg.viewBox_ 0 0 57 50
        , Svg.width_ size
        , Svg.height_ size
        ]
        [ Svg.path
            [ d "M28.4 6s.2-.4 1-1.2c6.2-6 16.2-6 22.3 0 6.1 6 6.1 16 0 22l-22.4 22c-.2.3-.6.4-1 .4V6z"
            , Svg.fill_ Palette.pinkRed
            ]
            []
        , Svg.path
            [ d "M28.4 6s-.2-.4-1-1.2c-6.2-6-16.2-6-22.3 0-6.1 6-6.1 16 0 22l22.3 22c.3.3.6.4 1 .4V6z"
            , Svg.fill_ Palette.crimson
            ]
            []
        ]



-- Beating


beating : Element msg
beating =
    Animated.el heartBeat [] static



-- Breaking


breaking : Element msg
breaking =
    heartBreak


broken : Element msg
broken =
    heartBreak


heartBreak : Element msg
heartBreak =
    Icon.el
        [ Svg.viewBox_ -5 0 65 49
        , Svg.height_ size
        , Svg.width_ size
        ]
        [ Animated.path breakLeft
            [ d "M28 4.5a15.5 15.5 0 0 1 22 21.9l-22 22c-.3.2-.7.4-1 .4v-8.9l-5.7-9.8 5.7-8.7-5.7-8.3L27 5.7l1-1.2z"
            , Svg.fill_ Palette.lightGray
            , Style.originBottom
            ]
            []
        , Animated.path breakRight
            [ d "M26.4 4.5A15.5 15.5 0 0 0 4.5 26.4l22 22c.3.2.6.4 1 .4v-8.9l-5.6-9.8 5.5-8.7-5.5-8.3 5.5-7.4-1-1.2z"
            , Svg.fill_ Palette.silver
            , Style.originBottom
            ]
            []
        ]



-- Animations


heartBeat : Animation
heartBeat =
    Animation.steps
        { startAt = [ P.scale 1 ]
        , options = [ Animation.loop ]
        }
        [ Animation.step 500 [ P.scale 1.15 ]
        , Animation.step 500 [ P.scale 1 ]
        ]


breakRight : Animation
breakRight =
    Animation.fromTo
        { duration = 200
        , options = [ Animation.delay 200, zippy ]
        }
        [ P.x 0, P.rotate 0 ]
        [ P.x -3, P.rotate -2 ]


breakLeft : Animation
breakLeft =
    Animation.fromTo
        { duration = 200
        , options = [ Animation.delay 200, zippy ]
        }
        [ P.x 0, P.rotate 0 ]
        [ P.x 3, P.rotate 2 ]


zippy : Animation.Option
zippy =
    Animation.cubic 0 -2.85 0.67 2.83



-- Config


size : number
size =
    35
