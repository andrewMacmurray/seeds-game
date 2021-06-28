module Element.Sprite.Butterfly exposing
    ( hovering
    , resting
    )

import Element exposing (..)
import Element.Palette as Palette
import Simple.Animation as Animation exposing (Animation)
import Simple.Animation.Property as P
import Svg exposing (Svg)
import Svg.Attributes exposing (..)
import Utils.Animated as Animated
import Utils.Svg as Svg exposing (height_, transformOrigin_, viewBox_, width_)



-- Hovering


type alias HoveringOptions =
    { delay : Animation.Millis
    }


hovering : HoveringOptions -> Element msg
hovering options =
    Animated.el (hoverUpDown options)
        [ Element.width Element.fill ]
        (butterfly
            { color = Palette.softRed
            , size = 20
            , speed = 1
            , delay = 0
            }
        )


hoverUpDown : HoveringOptions -> Animation
hoverUpDown options =
    Animation.steps
        { startAt = [ P.x 0, P.y 0 ]
        , options = [ Animation.loop, Animation.delay options.delay ]
        }
        [ Animation.step 400 [ P.x 1, P.y -8 ]
        , Animation.step 300 [ P.x 0, P.y 1 ]
        , Animation.step 400 [ P.x 1, P.y -5 ]
        , Animation.step 300 [ P.x 0, P.y 0 ]
        ]



-- Resting


type alias RestingOptions =
    { delay : Animation.Millis
    }


resting : RestingOptions -> Element msg
resting options =
    butterfly
        { color = Palette.crimson
        , size = 20
        , speed = 0.3
        , delay = options.delay * 2
        }


flapRightWing : Options -> Animation
flapRightWing options =
    Animation.steps
        { startAt = [ P.rotate -10 ]
        , options = [ Animation.loop, Animation.delay options.delay ]
        }
        [ Animation.step (flapDuration options.speed) [ P.rotate 20 ]
        , Animation.step (flapDuration options.speed) [ P.rotate -10 ]
        ]


flapLeftWing : Options -> Animation
flapLeftWing options =
    Animation.steps
        { startAt = [ P.rotate 10 ]
        , options = [ Animation.loop, Animation.delay options.delay ]
        }
        [ Animation.step (flapDuration options.speed) [ P.rotate -20 ]
        , Animation.step (flapDuration options.speed) [ P.rotate 10 ]
        ]


flapDuration : Float -> Int
flapDuration x =
    round (300 / x)


type alias Options =
    { color : Color
    , size : Float
    , speed : Float
    , delay : Animation.Millis
    }


butterfly : Options -> Element msg
butterfly ({ color, size } as options) =
    el
        [ Element.width Element.fill
        , Element.inFront
            (Animated.el (flapLeftWing options)
                [ Element.width Element.fill
                ]
                (html (leftWing size color))
            )
        ]
        (Animated.el (flapRightWing options)
            [ Element.width Element.fill
            ]
            (html (rightWing size color))
        )


leftWing : Float -> Color -> Svg msg
leftWing size color =
    Svg.svg [ viewBox_ 0 0 70 40, width_ size, height_ size ]
        [ Svg.g [ style (transformOrigin_ 35 35) ]
            [ Svg.ellipse
                [ cx "6028.8"
                , cy "3886.5"
                , rx "6.2"
                , ry "11.9"
                , Svg.fill_ color
                , transform "matrix(-.97322 1.3899 -1.47584 -1.03235 11623.4 -4346.7)"
                ]
                []
            ]
        ]


rightWing : Float -> Color -> Svg msg
rightWing size color =
    Svg.svg [ viewBox_ 0 0 70 40, width_ size, height_ size ]
        [ Svg.g [ style (transformOrigin_ 35 35) ]
            [ Svg.ellipse
                [ cx "6028.8"
                , cy "3886.5"
                , rx "6.2"
                , ry "11.9"
                , Svg.fill_ color
                , transform "matrix(.97288 1.38941 -1.47536 1.03306 -82 -12371)"
                ]
                []
            ]
        ]
