module Css.Animation exposing
    ( AnimationOption
    , animation
    , cubicBezier
    , delay
    , ease
    , easeOut
    , infinite
    , linear
    )

import Css.Style as Style exposing (Style)
import Css.Unit exposing (ms)



-- animatedDiv =
--     div
--         [ style [ animation "fade-in" 500 [ delay 500, infinite ] ] ]
--         []


type AnimationOption
    = AnimationOption Style


animation : String -> Int -> List AnimationOption -> Style
animation name duration options =
    [ [ animationName name
      , animationDuration duration
      , fillForwards
      ]
    , toStyles options
    ]
        |> List.concat
        |> Style.compose


delay : Int -> AnimationOption
delay duration =
    animationOption <| animationDelay duration


ease : AnimationOption
ease =
    animationOption <| animationTimingFunction "ease"


easeOut : AnimationOption
easeOut =
    animationOption <| animationTimingFunction "ease-out"


linear : AnimationOption
linear =
    animationOption <| animationTimingFunction "linear"


cubicBezier : Float -> Float -> Float -> Float -> AnimationOption
cubicBezier a b c d =
    animationOption <| animationTimingFunction (cubicBezier_ a b c d)


infinite : AnimationOption
infinite =
    animationOption <| animationIterationCount "infinite"



-- Styles


animationName : String -> Style
animationName =
    Style.property "animation-name"


animationDuration : Int -> Style
animationDuration n =
    Style.property "animation-duration" <| ms <| toFloat n


animationDelay : Int -> Style
animationDelay n =
    Style.property "animation-delay" <| ms <| toFloat n


animationTimingFunction : String -> Style
animationTimingFunction =
    Style.property "animation-timing-function"


animationIterationCount : String -> Style
animationIterationCount =
    Style.property "animation-iteration-count"


fillForwards : Style
fillForwards =
    Style.property "animation-fill-mode" "forwards"



-- Helpers


animationOption : Style -> AnimationOption
animationOption =
    AnimationOption


toStyles : List AnimationOption -> List Style
toStyles =
    List.map (\(AnimationOption s) -> s)


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
