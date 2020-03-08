module View.Icon.Sprite.Bee exposing
    ( animate
    , bee
    )

import Animation
import Animation.Keyframes as Keyframes
import Animation.Property as P
import Animation.Timeline as Timeline
import Html exposing (Html)
import Svg exposing (Svg)
import Svg.Attributes exposing (..)
import Utils.Svg exposing (height_, viewBox_, width_)


animate : List ( Float, Html msg ) -> Html msg
animate bees =
    Animation.options
        |> Animation.infinite
        |> Animation.repeatDelay 2
        |> Timeline.sequence (List.map sequenceBee bees)
        |> Timeline.animate


sequenceBee : ( Float, Html msg ) -> Timeline.Timeline msg
sequenceBee ( startTime, bee_ ) =
    bee_
        |> Timeline.keyframes hoverInOut
        |> Timeline.startAt startTime


hoverInOut : Keyframes.Keyframes msg
hoverInOut =
    Keyframes.animation
        [ Keyframes.frame [ P.duration 0, P.x -10, P.y -30, P.opacity 0 ]
        , Keyframes.frame [ P.duration 0.2, P.x 100, P.y 100, P.opacity 1 ]
        , Keyframes.frame [ P.duration 3.2, P.x 100, P.y 100 ]
        , Keyframes.frame [ P.duration 0.2, P.x 200, P.y 0, P.opacity 0 ]
        ]


bee : Svg msg
bee =
    Svg.svg [ viewBox_ 0 0 71 85, width_ 20, height_ 20 ]
        [ Svg.g [ transform "matrix(-1.56806 0 0 2.2802 5009.8 -4558)" ]
            [ Svg.clipPath [ id "bee-body" ] [ Svg.ellipse [ cx "3173.1", cy "2022.1", rx "20", ry "9.9" ] [] ]
            , Svg.g [ clipPath "url(#bee-body)" ]
                [ Svg.path [ fill "#ffc200", d "M3149.8 1998.9h11.3v36.9h-11.3z" ] []
                , Svg.path [ d "M3161 1999h11.4v36.9H3161z" ] []
                , Svg.path [ fill "#ffc200", d "M3172.3 1999h11.3v36.9h-11.3z" ] []
                , Svg.path [ d "M3183.6 1998.9h11.3v36.9h-11.3z" ] []
                ]
            ]
        ]
