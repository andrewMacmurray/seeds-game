port module Ports exposing
    ( cacheProgress
    , cacheTimes
    , clearCache
    , clearCache_
    , fadeMusic
    , generateBounceKeyframes
    , introMusicPlaying
    , playIntroMusic
    )

import Types exposing (RawProgress, Times)


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
