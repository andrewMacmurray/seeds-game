module Scenes.Intro.State exposing (..)

import Config.Color as Color
import Helpers.Delay exposing (sequenceMs)
import Ports exposing (animate)
import Scenes.Intro.Types exposing (..)
import Task
import Window exposing (resizes, size)


init : ( IntroModel, Cmd IntroMsg )
init =
    initialState ! [ Task.perform WindowSize size ]


initialState : IntroModel
initialState =
    { scene = DyingLandscape Alive Hidden
    , backdrop = Color.skyGreen
    , text = "Our world is dying"
    , textColor = "rgb(105, 88, 35)"
    , textVisible = False
    , window = { width = 0, height = 0 }
    }


update : IntroMsg -> IntroModel -> ( IntroModel, Cmd IntroMsg )
update msg model =
    case msg of
        TransitionToDead ->
            model
                ! [ sequenceMs
                        [ ( 0, ShowDyingLandscape )
                        , ( 4000, SetBackdrop "rgb(255, 211, 67)" )
                        , ( 1000, ShowText )
                        , ( 1000, KillEnvironment )
                        , ( 3000, HideDyingLandscape )
                        , ( 2000, HideText )
                        , ( 1000, SetText "We must save our seeds" )
                        , ( 500, ShowGrowingSeeds )
                        , ( 2000, HideText )
                        , ( 500, HideGrowingSeeds )
                        , ( 0, SetTextColor "#FFF" )
                        , ( 500, SetText "So they may bloom again on a new world" )
                        , ( 1500, InitRollingHills )
                        , ( 100, ShowRollingHills )
                        , ( 500, SetBackdrop "#5BCA78" )
                        , ( 500, BloomFlowers )
                        ]
                  ]

        ShowDyingLandscape ->
            { model | scene = DyingLandscape Alive Entering } ! []

        HideDyingLandscape ->
            { model | scene = DyingLandscape Dead Leaving } ! []

        ShowGrowingSeeds ->
            { model | scene = GrowingSeeds Entering } ! []

        HideGrowingSeeds ->
            { model | scene = GrowingSeeds Leaving } ! []

        ShowRollingHills ->
            { model | scene = BloomingFlowers Entering } ! [ animate () ]

        InitRollingHills ->
            { model | scene = BloomingFlowers Hidden } ! []

        BloomFlowers ->
            { model | scene = BloomingFlowers Visible } ! []

        Reset ->
            reset model ! []

        ShowText ->
            { model | textVisible = True } ! []

        SetText text ->
            { model | text = text, textVisible = True } ! []

        HideText ->
            { model | textVisible = False } ! []

        SetBackdrop bg ->
            { model | backdrop = bg } ! []

        SetTextColor color ->
            { model | textColor = color } ! []

        KillEnvironment ->
            { model | scene = DyingLandscape Dead Visible } ! []

        WindowSize size ->
            { model | window = size } ! []


reset : IntroModel -> IntroModel
reset model =
    { model
        | textVisible = False
        , text = "Our world is dying"
        , textColor = "rgb(105, 88, 35)"
        , scene = DyingLandscape Alive Hidden
        , backdrop = Color.skyGreen
    }


subscriptions : IntroModel -> Sub IntroMsg
subscriptions _ =
    resizes WindowSize
