module View.Icon.Sprite.Butterfly exposing (resting)

import Animation
import Animation.Keyframes as Keyframes
import Animation.Property as P
import Css.Style as Style
import Html exposing (div)
import Svg
import Svg.Attributes exposing (..)
import Utils.Svg exposing (height_, viewBox_, width_)


resting delay =
    butterfly2
        { color = "#E55E26"
        , size = 20
        , delay = delay
        }


animateRightWing : Float -> Keyframes.Keyframes msg
animateRightWing delay =
    Animation.options
        |> configureWing delay
        |> Keyframes.frames
            [ Keyframes.frame [ P.duration 0.3, P.rotation -10 ]
            , Keyframes.frame [ P.duration 0.3, P.rotation 20 ]
            ]


animateLeftWing : Float -> Keyframes.Keyframes msg
animateLeftWing delay =
    Animation.options
        |> configureWing delay
        |> Keyframes.frames
            [ Keyframes.frame [ P.duration 0.3, P.rotation 10 ]
            , Keyframes.frame [ P.duration 0.3, P.rotation -20 ]
            ]


configureWing : Float -> Animation.Options msg -> Animation.Options msg
configureWing delay =
    Animation.infinite >> Animation.yoyo >> Animation.delay delay


butterfly2 { color, delay, size } =
    div []
        [ div [ class "absolute" ] [ rightWing size color |> Keyframes.animate (animateRightWing delay) ]
        , div [ class "absolute" ] [ leftWing size color |> Keyframes.animate (animateLeftWing delay) ]
        ]


leftWing size color =
    Svg.svg [ viewBox_ 0 0 70 40, width_ size, height_ size ]
        [ Svg.g [ Style.style [ Style.transformOriginPx 35 35 ] ]
            [ Svg.ellipse
                [ cx "6028.8"
                , cy "3886.5"
                , rx "6.2"
                , ry "11.9"
                , fill color
                , transform "matrix(-.97322 1.3899 -1.47584 -1.03235 11623.4 -4346.7)"
                ]
                []
            ]
        ]


rightWing size color =
    Svg.svg [ viewBox_ 0 0 70 40, width_ size, height_ size ]
        [ Svg.g [ Style.style [ Style.transformOriginPx 35 35 ] ]
            [ Svg.ellipse
                [ cx "6028.8"
                , cy "3886.5"
                , rx "6.2"
                , ry "11.9"
                , fill color
                , transform "matrix(.97288 1.38941 -1.47536 1.03306 -82 -12371)"
                ]
                []
            ]
        ]
