module Game.Lives exposing
    ( Cache
    , Lives
    , decrement
    , fromCache
    , remaining
    , timeTillNextLife
    , toCache
    , update
    , view
    )

import Countdown exposing (Countdown)
import Css.Style as Style exposing (..)
import Css.Transform exposing (scale)
import Element.Icon.Heart as Heart
import Html exposing (..)
import Html.Attributes exposing (class)
import Time exposing (posixToMillis)



-- Lives


type Lives
    = Lives Cache


type alias Cache =
    { lastPlayed : Int
    , timeTillNextLife : Int
    }



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


timeTillNextLife : Lives -> Maybe Countdown
timeTillNextLife (Lives cache) =
    let
        minutes =
            modBy max (cache.timeTillNextLife // minute)

        seconds =
            modBy 60 (cache.timeTillNextLife // second)
    in
    if cache.timeTillNextLife == 0 then
        Nothing

    else
        Just (Countdown.init minutes seconds)



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



-- View


type alias ViewModel =
    { active : Bool
    , currentLife : Bool
    , breaking : Bool
    }


view : Lives -> Html msg
view lives =
    List.range 1 max
        |> List.map (viewModel (remaining lives))
        |> List.map heart
        |> div []


viewModel : Int -> Int -> ViewModel
viewModel remaining_ life =
    { active = life <= remaining_
    , currentLife = life == remaining_
    , breaking = life == remaining_ + 1
    }


heart : ViewModel -> Html msg
heart { active, currentLife, breaking } =
    let
        visibleHeart =
            if active then
                Heart.alive

            else if breaking then
                Heart.breaking

            else
                Heart.broken
    in
    div
        [ style
            [ width 35
            , height 35
            , marginLeft 10
            , marginRight 10
            , Style.applyIf (not active) (transform [ scale 1.11 ])
            , Style.applyIf currentLife Heart.beatingAnimation
            ]
        , class "dib"
        ]
        [ visibleHeart ]