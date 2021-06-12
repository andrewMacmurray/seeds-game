module Utils.Unit exposing
    ( deg
    , pc
    , px
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
