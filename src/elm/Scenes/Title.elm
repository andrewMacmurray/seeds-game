module Scenes.Title exposing
    ( Destination(..)
    , Model
    , Msg
    , init
    , subscriptions
    , update
    , view
    )

import Config.Scale as ScaleConfig
import Css.Animation exposing (animation, delay, linear)
import Css.Color exposing (..)
import Css.Style as Style exposing (..)
import Data.Exit as Exit exposing (continue, exitWith)
import Data.Level.Types exposing (Progress)
import Data.Levels as Levels
import Data.Visibility as Visibility exposing (..)
import Helpers.Delay exposing (sequence)
import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Ports exposing (introMusicPlaying, playIntroMusic)
import Shared exposing (Window)
import Views.Seed.Circle exposing (foxglove)
import Views.Seed.Mono exposing (rose)
import Views.Seed.Twin exposing (lupin, marigold, sunflower)



-- Model


type alias Model =
    { shared : Shared.Data
    , fadeDirection : FadeDirection
    }


type Msg
    = FadeSeeds
    | PlayIntro
    | IntroMusicPlaying Bool
    | GoToIntro
    | GoToHub


type FadeDirection
    = Appearing
    | Disappearing


type Destination
    = Hub
    | Intro


init : Shared.Data -> Model
init shared =
    { shared = shared
    , fadeDirection = Appearing
    }


update : Msg -> Model -> Exit.With Destination ( Model, Cmd Msg )
update msg model =
    case msg of
        FadeSeeds ->
            continue { model | fadeDirection = Disappearing } []

        PlayIntro ->
            continue model [ playIntroMusic () ]

        IntroMusicPlaying _ ->
            continue model
                [ sequence [ ( 0, FadeSeeds ), ( 2000, GoToIntro ) ]
                ]

        GoToIntro ->
            exitWith Intro model []

        GoToHub ->
            exitWith Hub model []


subscriptions : Model -> Sub Msg
subscriptions _ =
    introMusicPlaying IntroMusicPlaying



-- View


view : Model -> Html Msg
view { shared, fadeDirection } =
    div
        [ class "absolute left-0 right-0 z-5 tc"
        , style [ bottom <| toFloat shared.window.height / 2.4 ]
        ]
        [ div [] [ seeds fadeDirection ]
        , p
            [ styles
                [ [ color darkYellow, marginTop 45 ]
                , fadeInStyles fadeDirection 1500 500
                , fadeOutStyles fadeDirection 1000 500
                ]
            , class "f3 tracked-mega"
            ]
            [ text "seeds" ]
        , button
            [ styles
                [ [ borderNone
                  , marginTop 15
                  , color white
                  , backgroundColor lightOrange
                  ]
                , fadeInStyles fadeDirection 800 2500
                , fadeOutStyles fadeDirection 1000 0
                ]
            , class "outline-0 br4 pv2 ph3 f5 pointer sans-serif tracked-mega"
            , handleStart shared.progress
            ]
            [ text "PLAY" ]
        ]


handleStart : Levels.Key -> Attribute Msg
handleStart progress =
    if progress == Levels.empty then
        onClick PlayIntro

    else
        onClick GoToHub


percentWindowHeight : Float -> Window -> Float
percentWindowHeight percent window =
    toFloat window.height / 100 * percent


seeds : FadeDirection -> Html msg
seeds fadeDirection =
    div
        [ style
            [ maxWidth 450
            , paddingLeft ScaleConfig.windowPadding
            , paddingRight ScaleConfig.windowPadding
            ]
        , class "flex center"
        ]
        (List.map3 (fadeSeeds fadeDirection)
            (seedEntranceDelays 500)
            (seedExitDelays 500)
            [ foxglove
            , marigold
            , sunflower
            , lupin
            , rose
            ]
        )


seedEntranceDelays : Int -> List Int
seedEntranceDelays interval =
    [ 3, 2, 1, 2, 3 ] |> List.map ((*) interval)


seedExitDelays : Int -> List Int
seedExitDelays interval =
    [ 0, 1, 2, 1, 0 ] |> List.map ((*) interval)


fadeSeeds : FadeDirection -> Int -> Int -> Html msg -> Html msg
fadeSeeds direction entranceDelay exitDelay seed =
    div
        [ styles
            [ fadeInStyles direction 1000 entranceDelay
            , fadeOutStyles direction 1000 exitDelay
            ]
        , class "mh2"
        ]
        [ seed ]


fadeOutStyles : FadeDirection -> Int -> Int -> List Style
fadeOutStyles direction duration delay =
    case direction of
        Disappearing ->
            [ fade direction duration delay
            , opacity 1
            ]

        Appearing ->
            []


fadeInStyles : FadeDirection -> Int -> Int -> List Style
fadeInStyles direction duration delay =
    case direction of
        Appearing ->
            [ fade direction duration delay
            , opacity 0
            ]

        Disappearing ->
            []


fade : FadeDirection -> Int -> Int -> Style
fade direction duration delayMs =
    let
        fadeAnimation name =
            animation name duration [ delay delayMs, linear ]
    in
    case direction of
        Appearing ->
            fadeAnimation "fade-in"

        Disappearing ->
            fadeAnimation "fade-out"
