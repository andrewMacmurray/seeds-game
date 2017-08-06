port module Data.Ports exposing (..)


port scrollToHubLevel : Int -> Cmd msg


port receiveHubLevelOffset : (Float -> msg) -> Sub msg


port getExternalAnimations : Float -> Cmd msg


port receiveExternalAnimations : (String -> msg) -> Sub msg
