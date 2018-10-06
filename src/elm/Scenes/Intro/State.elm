module Scenes.Intro.State exposing (init, initialState, sequence, subscriptions, update)

import Browser.Events
import Css.Color as Color
import Data.Visibility exposing (..)
import Data.Window as Window
import Helpers.Delay exposing (sequenceMs, trigger)
import Helpers.Exit exposing (ExitMsg, continue, exit)
import Scenes.Intro.Types exposing (..)
import Task


init : ( IntroModel, Cmd IntroMsg )
init =
    ( initialState
    , Cmd.batch
        [ -- FIXME
          -- Task.perform WindowSize size
          sequence
        ]
    )


initialState : IntroModel
initialState =
    { scene = DyingLandscape Alive Hidden
    , backdrop = Color.transparent
    , text = "Our world is dying"
    , textColor = Color.brownYellow
    , textVisible = False
    , window = { width = 0, height = 0 }
    }


sequence : Cmd IntroMsg
sequence =
    sequenceMs
        [ ( 100, SetBackdrop Color.skyGreen )
        , ( 1000, ShowDyingLandscape )
        , ( 4000, SetBackdrop Color.skyYellow )
        , ( 1000, ShowText )
        , ( 1000, KillEnvironment )
        , ( 2000, HideDyingLandscape )
        , ( 1000, HideText )
        , ( 1000, SetText "We must save our seeds" )
        , ( 500, SetBackdrop Color.lightGold )
        , ( 500, ShowGrowingSeeds )
        , ( 1500, HideText )
        , ( 500, HideGrowingSeeds )
        , ( 0, SetTextColor "#FFF" )
        , ( 500, SetText "So they may bloom again on a new world" )
        , ( 1500, InitRollingHills )
        , ( 100, ShowRollingHills )
        , ( 500, SetBackdrop Color.meadowGreen )
        , ( 500, BloomFlowers )
        , ( 4000, HideText )
        , ( 1500, IntroComplete )
        ]


update : IntroMsg -> IntroModel -> ( IntroModel, Cmd IntroMsg, ExitMsg () )
update msg model =
    case msg of
        ShowDyingLandscape ->
            continue { model | scene = DyingLandscape Alive Entering } []

        HideDyingLandscape ->
            continue { model | scene = DyingLandscape Dead Leaving } []

        ShowGrowingSeeds ->
            continue { model | scene = GrowingSeeds Entering } []

        HideGrowingSeeds ->
            continue { model | scene = GrowingSeeds Leaving } []

        ShowRollingHills ->
            continue { model | scene = RollingHills Entering } []

        InitRollingHills ->
            continue { model | scene = RollingHills Hidden } []

        BloomFlowers ->
            continue { model | scene = RollingHills Visible } []

        ShowText ->
            continue { model | textVisible = True } []

        SetText text ->
            continue { model | text = text, textVisible = True } []

        HideText ->
            continue { model | textVisible = False } []

        SetBackdrop bg ->
            continue { model | backdrop = bg } []

        SetTextColor color ->
            continue { model | textColor = color } []

        KillEnvironment ->
            continue { model | scene = DyingLandscape Dead Visible } []

        WindowSize width height ->
            continue { model | window = Window.Size width height } []

        IntroComplete ->
            exit model []


subscriptions : IntroModel -> Sub IntroMsg
subscriptions _ =
    Browser.Events.onResize WindowSize
