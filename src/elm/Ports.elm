port module Ports exposing
    ( cacheLives
    , cacheProgress
    , clearCache
    , fadeMusic
    , introMusicPlaying
    , playIntroMusic
    )

import Game.Config.Level as Level
import Lives


port cacheProgress : Level.Cache -> Cmd msg


port cacheLives : Lives.Cache -> Cmd msg


clearCache : Cmd msg
clearCache =
    clearCache_ ()


port clearCache_ : () -> Cmd msg


port playIntroMusic : () -> Cmd msg


port introMusicPlaying : (Bool -> msg) -> Sub msg


port fadeMusic : () -> Cmd msg
