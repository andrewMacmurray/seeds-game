module Css.Animation exposing (animation, cubicBezier, delay, ease, easeIn, easeInOut, easeOut, infinite, linear)

import Css.Style exposing (Style, compose, property)
import Css.Unit exposing (ms)



-- myDiv =
--     div
--         [ styles
--             [ animation (name "fade-in" 500 |> delay 500 |> infinite)
--             ]
--         ]
--         []


animation : String -> Int -> Style
animation name duration =
    compose
        [ animationName name
        , animationDuration duration
        , fillForwards
        ]


delay : Int -> Style -> Style
delay duration s =
    compose [ animationDelay duration, s ]


ease : Style -> Style
ease s =
    compose [ animationTimingFunction "ease", s ]


easeIn : Style -> Style
easeIn s =
    compose [ animationTimingFunction "ease-in", s ]


easeOut : Style -> Style
easeOut s =
    compose [ animationTimingFunction "ease-out", s ]


easeInOut : Style -> Style
easeInOut s =
    compose [ animationTimingFunction "ease-in-out", s ]


linear : Style -> Style
linear s =
    compose [ animationTimingFunction "linear", s ]


infinite : Style -> Style
infinite s =
    compose [ animationIterationCount "infinite", s ]


cubicBezier : Float -> Float -> Float -> Float -> Style -> Style
cubicBezier a b c d s =
    compose [ animationTimingFunction (cubicBezier_ a b c d), s ]



-- Styles


animationName : String -> Style
animationName =
    property "animation-name"


animationDuration : Int -> Style
animationDuration n =
    property "animation-duration" <| ms <| toFloat n


animationDelay : Int -> Style
animationDelay n =
    property "animation-delay" <| ms <| toFloat n


animationTimingFunction : String -> Style
animationTimingFunction =
    property "animation-timing-function"


animationIterationCount : String -> Style
animationIterationCount =
    property "animation-iteration-count"


fillForwards : Style
fillForwards =
    property "animation-fill-mode" "forwards"



-- Helpers


cubicBezier_ : Float -> Float -> Float -> Float -> String
cubicBezier_ a b c d =
    String.join ""
        [ "cubic-bezier("
        , String.fromFloat a
        , ","
        , String.fromFloat b
        , ","
        , String.fromFloat c
        , ","
        , String.fromFloat d
        , ")"
        ]
