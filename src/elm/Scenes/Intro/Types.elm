module Scenes.Intro.Types exposing (Environment(..), IntroModel, IntroMsg(..), Scene(..))

import Data.Visibility exposing (Visibility)
import Data.Window as Window


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
    | RollingHills Visibility


type Environment
    = Alive
    | Dead


type IntroMsg
    = ShowDyingLandscape
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
    | IntroComplete
    | WindowSize Int Int
