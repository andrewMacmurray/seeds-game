module Scenes.Title exposing
    ( Destination(..)
    , Model
    , Msg
    , getContext
    , init
    , menuOptions
    , subscriptions
    , update
    , updateContext
    , view
    )

import Context exposing (Context)
import Css.Animation exposing (animation, delay, linear)
import Css.Color as Color
import Css.Style as Style exposing (..)
import Data.Levels as Levels
import Data.Progress as Progress
import Data.Window as Window exposing (Window)
import Exit exposing (continue, exitWith)
import Helpers.Delay exposing (sequence)
import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Ports exposing (introMusicPlaying, playIntroMusic)
import Views.Menu as Menu
import Views.Seed.Circle exposing (chrysanthemum)
import Views.Seed.Mono exposing (rose)
import Views.Seed.Twin exposing (lupin, marigold, sunflower)



-- Model


type alias Model =
    { context : Context
    , fadeDirection : FadeDirection
    }


type Msg
    = FadeSeeds
    | PlayIntro
    | IntroMusicPlaying Bool
    | GoToIntro
    | GoToHub
    | GoToGarden


type FadeDirection
    = Appearing
    | Disappearing


type Destination
    = ToHub
    | ToIntro
    | ToGarden



-- Context


getContext : Model -> Context
getContext model =
    model.context


updateContext : (Context -> Context) -> Model -> Model
updateContext f model =
    { model | context = f model.context }


menuOptions : List (Menu.Option Msg)
menuOptions =
    [ Menu.option GoToHub "Levels"
    , Menu.option GoToGarden "Garden"
    ]



-- Init


init : Context -> Model
init context =
    { context = context
    , fadeDirection = Appearing
    }


update : Msg -> Model -> Exit.With Destination ( Model, Cmd Msg )
update msg model =
    case msg of
        FadeSeeds ->
            continue { model | fadeDirection = Disappearing } []

        PlayIntro ->
            continue (updateContext Context.disableMenu model) [ playIntroMusic () ]

        IntroMusicPlaying _ ->
            continue model
                [ sequence
                    [ ( 0, FadeSeeds )
                    , ( 2000, GoToIntro )
                    ]
                ]

        GoToIntro ->
            exitWith ToIntro model

        GoToHub ->
            exitWith ToHub model

        GoToGarden ->
            exitWith ToGarden model


subscriptions : Model -> Sub Msg
subscriptions _ =
    introMusicPlaying IntroMusicPlaying


view : Model -> Html Msg
view { context, fadeDirection } =
    div
        [ class "absolute left-0 right-0 z-1 tc"
        , style [ bottom <| toFloat context.window.height / 2.4 ]
        ]
        [ div [] [ seeds fadeDirection ]
        , p
            [ styles
                [ [ color Color.darkYellow, marginTop 45 ]
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
                  , color Color.white
                  , backgroundColor Color.lightOrange
                  ]
                , fadeInStyles fadeDirection 800 2500
                , fadeOutStyles fadeDirection 1000 0
                ]
            , class "outline-0 br4 pv2 ph3 f5 pointer sans-serif tracked-mega"
            , handleStart <| Progress.reachedLevel context.progress
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
            , paddingLeft Window.padding
            , paddingRight Window.padding
            ]
        , class "flex center"
        ]
        (List.map3 (fadeSeeds fadeDirection)
            (seedEntranceDelays 500)
            (seedExitDelays 500)
            [ chrysanthemum
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
