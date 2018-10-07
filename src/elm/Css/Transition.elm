module Css.Transition exposing
    ( cubicBezier
    , delay
    , easeOut
    , linear
    , transition
    , transitionAll
    )

import Css.Style as Style exposing (Style)
import Css.Unit exposing (cubicBezier_, ms)


type TransitionOption
    = TransitionOption Style


transition : String -> Int -> List TransitionOption -> Style
transition prop duration options =
    [ [ transitionProperty prop
      , transitionDuration duration
      , transitionTimingFunction "ease"
      ]
    , toStyles options
    ]
        |> List.concat
        |> Style.compose


transitionAll : Int -> List TransitionOption -> Style
transitionAll =
    transition "all"


easeOut : TransitionOption
easeOut =
    transitionOption <| transitionTimingFunction "ease-out"


linear : TransitionOption
linear =
    transitionOption <| transitionTimingFunction "linear"


cubicBezier : Float -> Float -> Float -> Float -> TransitionOption
cubicBezier a b c d =
    transitionOption <| transitionTimingFunction <| cubicBezier_ a b c d


delay : Int -> TransitionOption
delay =
    transitionOption << transitionDelay



-- Styles


transitionDelay : Int -> Style
transitionDelay n =
    Style.property "transition-delay" <| ms <| toFloat n


transitionDuration : Int -> Style
transitionDuration n =
    Style.property "transition-duration" <| ms <| toFloat n


transitionTimingFunction : String -> Style
transitionTimingFunction =
    Style.property "transition-timing-function"


transitionProperty : String -> Style
transitionProperty =
    Style.property "transition-property"



-- Helpers


transitionOption : Style -> TransitionOption
transitionOption =
    TransitionOption


toStyles : List TransitionOption -> List Style
toStyles =
    List.map (\(TransitionOption s) -> s)
