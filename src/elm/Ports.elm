port module Ports exposing (..)

import Types exposing (RawProgress, Times)


port scrollToHubLevel : Int -> Cmd msg


port receiveHubLevelOffset : (Float -> msg) -> Sub msg


port generateBounceKeyframes : Float -> Cmd msg


port cacheProgress : RawProgress -> Cmd msg


port cacheTimes : Times -> Cmd msg


clearCache : Cmd msg
clearCache =
    clearCache_ ()


port clearCache_ : () -> Cmd msg


port playIntroMusic : () -> Cmd msg


port introMusicPlaying : (Bool -> msg) -> Sub msg


port fadeMusic : () -> Cmd msg
