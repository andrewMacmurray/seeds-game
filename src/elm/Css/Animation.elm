module Css.Animation exposing
    ( AnimationProperty
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


type AnimationProperty
    = AnimationProperty Style


animation : String -> Int -> List AnimationProperty -> Style
animation name duration props =
    [ [ animationName name
      , animationDuration duration
      , fillForwards
      ]
    , propsToStyles props
    ]
        |> List.concat
        |> Style.compose


delay : Int -> AnimationProperty
delay duration =
    animationProperty <| animationDelay duration


ease : AnimationProperty
ease =
    animationProperty <| animationTimingFunction "ease"


easeOut : AnimationProperty
easeOut =
    animationProperty <| animationTimingFunction "ease-out"


linear : AnimationProperty
linear =
    animationProperty <| animationTimingFunction "linear"


cubicBezier : Float -> Float -> Float -> Float -> AnimationProperty
cubicBezier a b c d =
    animationProperty <| animationTimingFunction (cubicBezier_ a b c d)


infinite : AnimationProperty
infinite =
    animationProperty <| animationIterationCount "infinite"



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


animationProperty : Style -> AnimationProperty
animationProperty =
    AnimationProperty


propsToStyles : List AnimationProperty -> List Style
propsToStyles =
    List.map (\(AnimationProperty s) -> s)


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
