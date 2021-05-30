module Utils.Unit exposing
    ( deg
    , pc
    )


deg : Float -> String
deg n =
    String.fromFloat n ++ "deg"


pc : Float -> String
pc n =
    String.fromFloat n ++ "%"
