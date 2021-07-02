module Utils.Unit exposing
    ( cubicBezier_
    , deg
    , ms
    , pc
    , px
    , px_
    )


deg : Float -> String
deg n =
    String.fromFloat n ++ "deg"


pc : Float -> String
pc n =
    String.fromFloat n ++ "%"


px : Int -> String
px n =
    String.fromInt n ++ "px"


px_ : Float -> String
px_ n =
    String.fromFloat n ++ "px"


ms : Float -> String
ms n =
    String.fromFloat n ++ "ms"


cubicBezier_ : Float -> Float -> Float -> Float -> String
cubicBezier_ a b c d =
    String.concat
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
