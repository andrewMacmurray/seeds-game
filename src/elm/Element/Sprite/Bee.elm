module Element.Sprite.Bee exposing (sprite)

import Element exposing (Element)
import Simple.Animation as Animation exposing (Animation)
import Simple.Animation.Property as P
import Svg
import Svg.Attributes exposing (..)
import Utils.Animated as Animated
import Utils.Svg exposing (..)



-- Bee


type alias Options =
    { delay : Animation.Millis
    }



-- View


sprite : Options -> Element msg
sprite options =
    Animated.el (flyToPoint options) [] bee_


flyToPoint : Options -> Animation
flyToPoint options =
    Animation.steps
        { startAt = [ P.opacity 0, P.x -60, P.y -75 ]
        , options = [ Animation.delay options.delay, Animation.loop ]
        }
        [ Animation.step 300 [ P.opacity 1, P.x 0, P.y 0 ]
        , Animation.wait 3500
        , Animation.step 300 [ P.opacity 0, P.x 60, P.y -75 ]
        , Animation.wait 3000
        ]


bee_ : Element msg
bee_ =
    Element.html
        (Svg.svg [ viewBox_ 0 0 71 85, width_ 20, height_ 20 ]
            [ Svg.g [ transform "matrix(-1.56806 0 0 2.2802 5009.8 -4558)" ]
                [ Svg.clipPath [ id "bee-body" ]
                    [ Svg.ellipse
                        [ cx "3173.1"
                        , cy "2022.1"
                        , rx "20"
                        , ry "9.9"
                        ]
                        []
                    ]
                , Svg.g [ clipPath "url(#bee-body)" ]
                    [ Svg.path [ fill "#ffc200", d "M3149.8 1998.9h11.3v36.9h-11.3z" ] []
                    , Svg.path [ d "M3161 1999h11.4v36.9H3161z" ] []
                    , Svg.path [ fill "#ffc200", d "M3172.3 1999h11.3v36.9h-11.3z" ] []
                    , Svg.path [ d "M3183.6 1998.9h11.3v36.9h-11.3z" ] []
                    ]
                ]
            ]
        )
