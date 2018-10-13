port module Ports exposing
    ( RawProgress
    , cacheProgress
    , cacheLives
    , clearCache
    , clearCache_
    , fadeMusic
    , generateBounceKeyframes
    , introMusicPlaying
    , playIntroMusic
    )

import Data.Lives as Lives


type alias RawProgress =
    { world : Int
    , level : Int
    }


port generateBounceKeyframes : Float -> Cmd msg


port cacheProgress : RawProgress -> Cmd msg


port cacheLives : Lives.Cache -> Cmd msg


clearCache : Cmd msg
clearCache =
    clearCache_ ()


port clearCache_ : () -> Cmd msg


port playIntroMusic : () -> Cmd msg


port introMusicPlaying : (Bool -> msg) -> Sub msg


port fadeMusic : () -> Cmd msg
