port module Data.Ports exposing (..)


port scrollToLevel : Int -> Cmd msg


port receiveLevelOffset : (Float -> msg) -> Sub msg
