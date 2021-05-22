module Scene.Garden.Cornflower.Sprites exposing (..)

import Element exposing (Element)
import Simple.Animation as Animation exposing (Animation)
import Simple.Animation.Property as P
import Svg
import Svg.Attributes exposing (..)
import Utils.Animated as Animated
import Utils.Svg exposing (height_, viewBox_, width_)


ladybird : Animation.Millis -> Element msg
ladybird delay =
    Animated.el (backAndForth delay) [] ladybird_


backAndForth : Animation.Millis -> Animation
backAndForth delay =
    Animation.steps
        { startAt = [ P.y 0, P.rotate 0 ]
        , options = [ Animation.delay delay, Animation.loop ]
        }
        [ Animation.step 1000 [ P.y 50, P.rotate 0 ]
        , Animation.wait 1200
        , Animation.step 500 [ P.y 50, P.rotate 180 ]
        , Animation.wait 1200
        , Animation.step 500 [ P.y 0, P.rotate 180 ]
        , Animation.wait 600
        , Animation.step 500 [ P.y 0, P.rotate 360 ]
        , Animation.wait 1500
        ]


ladybird_ : Element msg
ladybird_ =
    Element.html
        (Svg.svg
            [ viewBox_ 0 0 8 9
            , width_ 18
            , height_ 19
            ]
            [ Svg.path [ d "M3.5 8.6c-2 0-3.5-2-3.5-4.3C0 1.9 1.6 0 3.5 0v8.6z", fill "#e24132" ] []
            , Svg.path
                [ d "M3.5 8.6c2 0 3.5-2 3.5-4.3C7 1.9 5.5 0 3.5 0v8.6z"
                , fill "#f30748"
                ]
                []
            , Svg.circle [ cx "2.3", cy "6", r ".7" ] []
            , Svg.circle [ cx "1.7", cy "3.1", r ".7" ] []
            , Svg.circle [ cx "4.7", cy "6", r ".7" ] []
            , Svg.circle [ cx "5.3", cy "3.1", r ".7" ] []
            ]
        )
