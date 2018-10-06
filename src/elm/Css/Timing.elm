module Css.Timing exposing
    ( TimingFunction(..)
    , timingToString
    )


type TimingFunction
    = Ease
    | Linear
    | EaseIn
    | EaseOut
    | EaseInOut
    | CubicBezier Float Float Float Float


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
            cubicBezier_ a b c d


cubicBezier_ : number -> number -> number -> number -> String
cubicBezier_ a b c d =
    String.join ""
        [ "cubic-bezier("
        , Debug.toString a
        , ","
        , Debug.toString b
        , ","
        , Debug.toString c
        , ","
        , Debug.toString d
        , ")"
        ]
