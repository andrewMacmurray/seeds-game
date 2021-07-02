port module Ports.Cache exposing
    ( clear
    , saveLives
    , saveProgress
    )

import Game.Config.Level as Level



-- Progress


port saveProgress : Level.Cache -> Cmd msg



-- Lives


type alias Lives =
    { lastPlayed : Int
    , timeTillNextLife : Int
    }


port saveLives : Lives -> Cmd msg



-- Clear


clear : Cmd msg
clear =
    clearCache_ ()


port clearCache_ : () -> Cmd msg
