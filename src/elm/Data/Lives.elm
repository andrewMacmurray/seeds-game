module Data.Lives exposing
    ( Cache
    , Lives
    , TimeTillNextLife
    , decrement
    , fromCache
    , max
    , remaining
    , timeTillNextLife
    , toCache
    , update
    )

import Time exposing (posixToMillis)


type alias Cache =
    { lastPlayed : Int
    , timeTillNextLife : Int
    }


type Lives
    = Lives Cache



-- Life State


fromCache : Time.Posix -> Maybe Cache -> Lives
fromCache now cache =
    case cache of
        Just c ->
            fromValidCache now c

        Nothing ->
            Lives
                { lastPlayed = posixToMillis now
                , timeTillNextLife = 0
                }


toCache : Lives -> Cache
toCache (Lives cache) =
    cache


update : Time.Posix -> Lives -> Lives
update now (Lives cache) =
    fromValidCache now cache


decrement : Lives -> Lives
decrement (Lives cache) =
    Lives { cache | timeTillNextLife = cache.timeTillNextLife + recoveryInterval }


remaining : Lives -> Int
remaining (Lives cache) =
    (cache.timeTillNextLife - recoveryInterval * max) // -recoveryInterval


max : Int
max =
    5



-- Time till next life


type alias TimeTillNextLife =
    { minutes : Int
    , seconds : Int
    }


timeTillNextLife : Lives -> Maybe TimeTillNextLife
timeTillNextLife (Lives cache) =
    let
        minutes =
            modBy 5 <| cache.timeTillNextLife // minute

        seconds =
            modBy 60 <| cache.timeTillNextLife // second
    in
    if cache.timeTillNextLife == 0 then
        Nothing

    else
        Just <| TimeTillNextLife minutes seconds



-- Helpers


fromValidCache : Time.Posix -> Cache -> Lives
fromValidCache now cache =
    Lives
        { lastPlayed = posixToMillis now
        , timeTillNextLife = diffTimes now cache
        }


diffTimes : Time.Posix -> Cache -> Int
diffTimes now cache =
    decrementAboveZero
        (posixToMillis now - cache.lastPlayed)
        cache.timeTillNextLife


recoveryInterval : Int
recoveryInterval =
    5 * minute


minute : Int
minute =
    60 * second


second : Int
second =
    1000


decrementAboveZero : Int -> Int -> Int
decrementAboveZero n1 n2 =
    let
        n3 =
            n2 - n1
    in
    if n3 <= 0 then
        0

    else
        n3
