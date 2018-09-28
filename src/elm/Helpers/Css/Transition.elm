module Helpers.Css.Transition exposing
    ( Transition
    , ease
    , easeAll
    , transition
    , transitionStyle
    , transitionSvg
    )

import Helpers.Css.Format exposing (ms)
import Helpers.Css.Style exposing (Style)
import Helpers.Css.Timing exposing (TimingFunction(..), timingToString)
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


ease : String -> Float -> Style
ease property duration =
    transitionStyle
        { property = property
        , duration = duration
        , timing = Ease
        , delay = Nothing
        }


transitionStyle : Transition -> Style
transitionStyle =
    transition >> (\b -> ( "transition", b ))


transitionSvg : Transition -> String
transitionSvg =
    transition >> (++) "transition: "


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
