module Types exposing (..)

import Data.Level.Settings exposing (Progress)
import Time exposing (Time)


type alias Flags =
    { now : Time
    , times : Maybe Times
    , rawProgress : Maybe RawProgress
    }


type alias Times =
    { timeTillNextLife : Time
    , lastPlayed : Time
    }


type alias RawProgress =
    { world : Int
    , level : Int
    }


fromProgress : Progress -> RawProgress
fromProgress ( world, level ) =
    RawProgress world level


toProgress : Maybe RawProgress -> Maybe Progress
toProgress =
    Maybe.map toProgress_


toProgress_ : RawProgress -> Progress
toProgress_ { world, level } =
    ( world, level )
