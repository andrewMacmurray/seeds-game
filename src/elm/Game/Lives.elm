module Game.Lives exposing
    ( Cache
    , Lives
    , decrement
    , init
    , remaining
    , save
    , timeTillNextLife
    , update
    , view
    )

import Element exposing (..)
import Element.Icon.Heart as Heart
import Element.Scale as Scale
import Ports.Cache as Cache
import Time
import Utils.Time as Time
import Utils.Time.Clock as Clock exposing (Clock)



-- Lives


type Lives
    = Lives Cache


type alias Cache =
    { lastPlayed : Int
    , timeTillNextLife : Int
    }



-- Save


save : Lives -> Cmd msg
save (Lives cache) =
    Cache.saveLives cache



-- Life State


init : Time.Posix -> Maybe Cache -> Lives
init now cache =
    case cache of
        Just c ->
            fromValidCache now c

        Nothing ->
            Lives
                { lastPlayed = Time.posixToMillis now
                , timeTillNextLife = 0
                }


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


timeTillNextLife : Lives -> Maybe Clock
timeTillNextLife (Lives cache) =
    if cache.timeTillNextLife == 0 then
        Nothing

    else
        Just (Clock.init cache.timeTillNextLife)



-- Helpers


fromValidCache : Time.Posix -> Cache -> Lives
fromValidCache now cache =
    Lives
        { lastPlayed = Time.posixToMillis now
        , timeTillNextLife = diffTimes now cache
        }


diffTimes : Time.Posix -> Cache -> Int
diffTimes now cache =
    decrementAboveZero
        (Time.posixToMillis now - cache.lastPlayed)
        cache.timeTillNextLife


recoveryInterval : Int
recoveryInterval =
    Time.minutes 5



-- View


type alias ViewModel =
    { active : Bool
    , currentLife : Bool
    , breaking : Bool
    }


view : Lives -> Element msg
view lives =
    List.range 1 max
        |> List.map (viewModel (remaining lives))
        |> List.map heart
        |> row [ spacing Scale.medium, centerX ]


viewModel : Int -> Int -> ViewModel
viewModel remaining_ life =
    { active = life <= remaining_
    , currentLife = life == remaining_
    , breaking = life == remaining_ + 1
    }


heart : ViewModel -> Element msg
heart model =
    el [ scale (toScale model) ] (visibleHeart model)


toScale : ViewModel -> Float
toScale model =
    if not model.active then
        1.11

    else
        1


visibleHeart : ViewModel -> Element msg
visibleHeart model =
    if model.currentLife then
        Heart.beating

    else if model.active then
        Heart.static

    else if model.breaking then
        Heart.breaking

    else
        Heart.broken



-- Util


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
