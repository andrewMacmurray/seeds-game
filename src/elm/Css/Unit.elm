module Css.Unit exposing (cubicBezier_, deg, ms, pc, px)


deg : Float -> String
deg n =
    String.fromFloat n ++ "deg"


px : Float -> String
px n =
    String.fromFloat n ++ "px"


pc : Float -> String
pc n =
    String.fromFloat n ++ "%"


ms : Float -> String
ms n =
    String.fromFloat n ++ "ms"


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
