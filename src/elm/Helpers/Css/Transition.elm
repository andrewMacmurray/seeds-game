module Helpers.Css.Transition
    exposing
        ( Transition
        , easeAll
        , transitionStyle
        )

import Helpers.Css.Style exposing (Style, ms)
import Helpers.Css.Timing exposing (TimingFunction(Ease), timingToString)
import Helpers.Maybe exposing (catMaybes)


type alias Transition =
    { property : String
    , duration : Float
    , timing : TimingFunction
    , delay : Maybe Float
    }



{-
   -- example usage
    myTransit =
        transitionStyle
            { property = "all"
            , duration = 500
            , timing = Ease
            , delay = Nothing
            }
-}


easeAll : Float -> Style
easeAll duration =
    transitionStyle
        { property = "all"
        , duration = duration
        , timing = Ease
        , delay = Nothing
        }


transitionStyle : Transition -> Style
transitionStyle =
    transition >> (,) "transition"


transition : Transition -> String
transition =
    combineAllProperties
        >> catMaybes
        >> String.join " "


combineAllProperties : Transition -> List (Maybe String)
combineAllProperties ts =
    [ Just <| ts.property
    , Just <| ms ts.duration
    , Just <| timingToString ts.timing
    , Maybe.map ms ts.delay
    ]
