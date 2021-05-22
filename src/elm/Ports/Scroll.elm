port module Ports.Scroll exposing (toCenter)


toCenter : String -> Cmd msg
toCenter =
    scrollToCenter


port scrollToCenter : String -> Cmd msg
