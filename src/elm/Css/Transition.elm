module Css.Transition exposing
    ( cubicBezier
    , delay
    , easeInOut
    , easeOut
    , linear
    , transition
    , transitionAll
    )

import Css.Style as Style exposing (Style)
import Utils.Unit as Unit


type Option
    = Option Style


transition : String -> Int -> List Option -> Style
transition prop duration options =
    [ [ transitionProperty prop
      , transitionDuration duration
      , transitionTimingFunction "ease"
      ]
    , toStyles options
    ]
        |> List.concat
        |> Style.compose


transitionAll : Int -> List Option -> Style
transitionAll =
    transition "all"


easeInOut : Option
easeInOut =
    option (transitionTimingFunction "ease-in-out")


easeOut : Option
easeOut =
    option (transitionTimingFunction "ease-out")


linear : Option
linear =
    option (transitionTimingFunction "linear")


cubicBezier : Float -> Float -> Float -> Float -> Option
cubicBezier a b c d =
    option (transitionTimingFunction (Unit.cubicBezier_ a b c d))


delay : Int -> Option
delay =
    option << transitionDelay



-- Styles


transitionDelay : Int -> Style
transitionDelay n =
    Style.property "transition-delay" (Unit.ms (toFloat n))


transitionDuration : Int -> Style
transitionDuration n =
    Style.property "transition-duration" (Unit.ms (toFloat n))


transitionTimingFunction : String -> Style
transitionTimingFunction =
    Style.property "transition-timing-function"


transitionProperty : String -> Style
transitionProperty =
    Style.property "transition-property"



-- Helpers


option : Style -> Option
option =
    Option


toStyles : List Option -> List Style
toStyles =
    List.map (\(Option s) -> s)
