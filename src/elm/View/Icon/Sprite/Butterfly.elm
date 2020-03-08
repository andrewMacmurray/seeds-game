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



--inFlight =
--    Svg.svg [ viewBox_ 0 0 280 140 ]
--        [ Svg.g []
--            [ Svg.g
--                [ y_ 0
--                , Style.style
--                    [ Animation.animation "vertical-flutter" 420 [ Animation.infinite, Animation.linear ]
--                    ]
--                ]
--                [ butterfly
--                    { color = "#E55E26"
--                    , size = 25
--                    , wingPhaseDuration = 400
--                    }
--                ]
--            , Svg.animateMotion
--                [ path "M13.067,23.957C-7.136,43.769 76.419,88.523 128.37,89.607C170.126,90.478 261.253,48.167 238.112,26.678C213.588,3.903 172.147,89.529 128.37,89.607C79.226,89.694 40.029,-2.481 13.067,23.957Z"
--                , repeatCount "indefinite"
--                , dur "50s"
--                ]
--                []
--            ]
--        ]
--hovering =
--    Svg.svg [ viewBox_ 0 0 280 140 ]
--        [ Svg.g []
--            [ Svg.g
--                [ y_ 0
--                , Style.style
--                    [ Animation.animation "vertical-flutter" 500 [ Animation.infinite, Animation.linear ]
--                    ]
--                ]
--                [ butterfly
--                    { color = "#E55E26"
--                    , size = 12
--                    , wingPhaseDuration = 500
--                    }
--                ]
--            , Svg.animateMotion
--                [ path "M30.321,61.304C30.321,61.304 5.025,21.519 30.764,21.519C56.503,21.519 30.321,61.304 30.321,61.304Z"
--                , repeatCount "indefinite"
--                , dur "30s"
--                ]
--                []
--            ]
--        ]
