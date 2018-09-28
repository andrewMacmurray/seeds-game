module Helpers.Css.Animation exposing
    ( Animation
    , AnimationOptions
    , FillMode(..)
    , IterationCount(..)
    , animateEase
    , animationStyle
    , animationWithOptionsStyle
    , animationWithOptionsSvg
    )

import Helpers.Css.Format exposing (ms)
import Helpers.Css.Style exposing (Style)
import Helpers.Css.Timing exposing (TimingFunction(..), timingToString)
import Helpers.Maybe exposing (catMaybes)


type alias AnimationOptions =
    { name : String
    , timing : TimingFunction
    , duration : Float
    , delay : Maybe Float
    , fill : FillMode
    , iteration : Maybe IterationCount
    }


type alias Animation =
    { name : String
    , duration : Float
    , timing : TimingFunction
    }


type FillMode
    = Forwards
    | Backwards
    | Both


type IterationCount
    = Infinite
    | Count Int



{- myAnim =
   animationWithOptionsStyle
       { name = "fade"
       , duration = 300
       , delay = Nothing
       , timing = EaseInOut
       , fill = Forwards
       , iteration = Nothing
       }

   -- ("animation", "fade 300ms ease-in-out forwards")
-}


animateEase : String -> Float -> Style
animateEase name duration =
    animationStyle
        { name = name
        , duration = duration
        , timing = Ease
        }


animationStyle : Animation -> Style
animationStyle =
    animation >> (\b -> ( "animation", b ))


animationWithOptionsStyle : AnimationOptions -> Style
animationWithOptionsStyle =
    animationWithOptions >> (\b -> ( "animation", b ))


animationWithOptionsSvg : AnimationOptions -> String
animationWithOptionsSvg =
    animationWithOptions >> (++) "animation: "


animation : Animation -> String
animation { name, duration, timing } =
    animationWithOptions
        { name = name
        , duration = duration
        , delay = Nothing
        , timing = timing
        , fill = Forwards
        , iteration = Nothing
        }


animationWithOptions : AnimationOptions -> String
animationWithOptions =
    combineProperties
        >> catMaybes
        >> String.join " "


combineProperties : AnimationOptions -> List (Maybe String)
combineProperties anim =
    [ Just anim.name
    , Just <| ms anim.duration
    , Just <| timingToString anim.timing
    , Maybe.map ms anim.delay
    , Just <| fillToString anim.fill
    , Maybe.map iterationToString anim.iteration
    ]


fillToString : FillMode -> String
fillToString =
    Debug.toString >> String.toLower


iterationToString : IterationCount -> String
iterationToString iter =
    case iter of
        Infinite ->
            "infinite"

        Count n ->
            Debug.toString n
