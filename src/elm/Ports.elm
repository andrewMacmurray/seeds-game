port module Ports exposing
    ( RawProgress
    , Times
    , cacheProgress
    , cacheTimes
    , clearCache
    , clearCache_
    , fadeMusic
    , generateBounceKeyframes
    , introMusicPlaying
    , playIntroMusic
    )


type alias Times =
    { timeTillNextLife : Float
    , lastPlayed : Float
    }


type alias RawProgress =
    { world : Int
    , level : Int
    }


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
