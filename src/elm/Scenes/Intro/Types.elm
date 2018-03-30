module Scenes.Intro.Types exposing (..)

import Window


type alias IntroModel =
    { scene : Scene
    , backdrop : String
    , text : String
    , textColor : String
    , textVisible : Bool
    , window : Window.Size
    }


type Scene
    = DyingLandscape Environment Visibility
    | GrowingSeeds Visibility
    | BloomingFlowers Visibility


type Visibility
    = Hidden
    | Visible
    | Leaving
    | Entering


type Environment
    = Alive
    | Dead


type IntroMsg
    = Reset
    | TransitionToDead
    | ShowDyingLandscape
    | HideDyingLandscape
    | ShowGrowingSeeds
    | HideGrowingSeeds
    | InitRollingHills
    | ShowRollingHills
    | BloomFlowers
    | SetBackdrop String
    | SetText String
    | SetTextColor String
    | ShowText
    | HideText
    | KillEnvironment
    | WindowSize Window.Size
