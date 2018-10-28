port module Ports exposing
    ( cacheLives
    , cacheProgress
    , clearCache
    , clearCache_
    , fadeMusic
    , generateBounceKeyframes
    , introMusicPlaying
    , playIntroMusic
    )

import Data.Levels as Levels
import Data.Lives as Lives


port generateBounceKeyframes : Float -> Cmd msg


port cacheProgress : Levels.Cache -> Cmd msg


port cacheLives : Lives.Cache -> Cmd msg


clearCache : Cmd msg
clearCache =
    clearCache_ ()


port clearCache_ : () -> Cmd msg


port playIntroMusic : () -> Cmd msg


port introMusicPlaying : (Bool -> msg) -> Sub msg


port fadeMusic : () -> Cmd msg
