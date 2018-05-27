module Scenes.Intro.State exposing (..)

import Config.Color as Color
import Data.Visibility exposing (..)
import Helpers.Delay exposing (sequenceMs, trigger)
import Helpers.OutMsg exposing (noOutMsg, withOutMsg)
import Scenes.Intro.Types exposing (..)
import Task
import Window exposing (resizes, size)


init : ( IntroModel, Cmd IntroMsg )
init =
    initialState
        ! [ Task.perform WindowSize size
          , sequence
          ]


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


update : IntroMsg -> IntroModel -> ( IntroModel, Cmd IntroMsg, Maybe IntroOutMsg )
update msg model =
    case msg of
        ShowDyingLandscape ->
            noOutMsg { model | scene = DyingLandscape Alive Entering } []

        HideDyingLandscape ->
            noOutMsg { model | scene = DyingLandscape Dead Leaving } []

        ShowGrowingSeeds ->
            noOutMsg { model | scene = GrowingSeeds Entering } []

        HideGrowingSeeds ->
            noOutMsg { model | scene = GrowingSeeds Leaving } []

        ShowRollingHills ->
            noOutMsg { model | scene = RollingHills Entering } []

        InitRollingHills ->
            noOutMsg { model | scene = RollingHills Hidden } []

        BloomFlowers ->
            noOutMsg { model | scene = RollingHills Visible } []

        ShowText ->
            noOutMsg { model | textVisible = True } []

        SetText text ->
            noOutMsg { model | text = text, textVisible = True } []

        HideText ->
            noOutMsg { model | textVisible = False } []

        SetBackdrop bg ->
            noOutMsg { model | backdrop = bg } []

        SetTextColor color ->
            noOutMsg { model | textColor = color } []

        KillEnvironment ->
            noOutMsg { model | scene = DyingLandscape Dead Visible } []

        WindowSize size ->
            noOutMsg { model | window = size } []

        IntroComplete ->
            withOutMsg model [] ExitIntro


subscriptions : IntroModel -> Sub IntroMsg
subscriptions _ =
    resizes WindowSize
