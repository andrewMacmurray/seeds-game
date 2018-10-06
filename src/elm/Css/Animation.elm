module Css.Animation exposing (animation, cubicBezier, delay, ease, easeIn, easeInOut, easeOut, infinite, linear)

import Css.Style exposing (Style, property)
import Css.Unit exposing (ms)



-- myDiv =
--     div
--         [ styles
--             [ animation "fade-in" 500
--                 |> delay 500
--                 |> infinite
--             ]
--         ]
--         []


animation : String -> Int -> List Style
animation name duration =
    [ animationName name
    , animationDuration duration
    , fillForwards
    ]


delay : Int -> List Style -> List Style
delay duration xs =
    animationDelay duration :: xs


ease : List Style -> List Style
ease xs =
    animationTimingFunction "ease" :: xs


easeIn : List Style -> List Style
easeIn xs =
    animationTimingFunction "ease-in" :: xs


easeOut : List Style -> List Style
easeOut xs =
    animationTimingFunction "ease-out" :: xs


easeInOut : List Style -> List Style
easeInOut xs =
    animationTimingFunction "ease-in-out" :: xs


linear : List Style -> List Style
linear xs =
    animationTimingFunction "linear" :: xs


infinite : List Style -> List Style
infinite xs =
    animationIterationCount "infinite" :: xs


cubicBezier : Float -> Float -> Float -> Float -> List Style -> List Style
cubicBezier a b c d xs =
    animationTimingFunction (cubicBezier_ a b c d) :: xs



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
