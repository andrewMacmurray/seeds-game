module Helpers.Css.Unit exposing (deg, ms, pc, px)


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
