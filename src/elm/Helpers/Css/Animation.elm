module Helpers.Css.Animation
    exposing
        ( AnimationOptions
        , Animation
        , TimingFunction(..)
        , FillMode(..)
        , IterationCount(..)
        , animationStyle
        , animationWithOptionsStyle
        )

import Formatting exposing (print)
import Helpers.Css.Format exposing (cubicBezier_)
import Helpers.Css.Style exposing (Style, ms)


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


type TimingFunction
    = Ease
    | Linear
    | EaseIn
    | EaseOut
    | EaseInOut
    | CubicBezier Float Float Float Float


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


animationStyle : Animation -> Style
animationStyle =
    animation >> (,) "animation"


animationWithOptionsStyle : AnimationOptions -> Style
animationWithOptionsStyle =
    animationWithOptions >> (,) "animation"


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
    propertyOrder
        >> catMaybes
        >> String.join " "


propertyOrder : AnimationOptions -> List (Maybe String)
propertyOrder anim =
    [ Just anim.name
    , Just <| ms anim.duration
    , Just <| timingToString anim.timing
    , Maybe.map ms anim.delay
    , Just <| fillToString anim.fill
    , Maybe.map iterationToString anim.iteration
    ]


timingToString : TimingFunction -> String
timingToString tf =
    case tf of
        Ease ->
            "ease"

        Linear ->
            "linear"

        EaseIn ->
            "ease-in"

        EaseOut ->
            "ease-out"

        EaseInOut ->
            "ease-in-out"

        CubicBezier a b c d ->
            (print cubicBezier_) a b c d


fillToString : FillMode -> String
fillToString =
    toString >> String.toLower


iterationToString : IterationCount -> String
iterationToString iter =
    case iter of
        Infinite ->
            "infinite"

        Count n ->
            toString n


catMaybes : List (Maybe a) -> List a
catMaybes xs =
    List.foldr cat [] xs


cat : Maybe a -> List a -> List a
cat val acc =
    case val of
        Just a ->
            a :: acc

        Nothing ->
            acc
