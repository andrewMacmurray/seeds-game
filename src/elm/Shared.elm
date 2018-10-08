module Shared exposing
    ( Data
    , hideLoadingScreen
    , incrementMessageIndex
    , incrementProgress
    , setCurrentLevel
    , setWindow
    , showLoadingScreen
    )

import Data.Background exposing (Background)
import Data.Level.Progress as Progress
import Data.Level.Types exposing (AllLevels, Progress)
import Data.Window as Window


type alias Data =
    { window : Window.Size
    , loadingScreen : Maybe Background
    , progress : Progress
    , currentLevel : Maybe Progress
    , successMessageIndex : Int
    }


setCurrentLevel : Maybe Progress -> Data -> Data
setCurrentLevel level data =
    { data | currentLevel = level }


showLoadingScreen : Background -> Data -> Data
showLoadingScreen background data =
    { data | loadingScreen = Just background }


hideLoadingScreen : Data -> Data
hideLoadingScreen data =
    { data | loadingScreen = Nothing }


setWindow : Int -> Int -> Data -> Data
setWindow width height data =
    { data | window = Window.Size width height }


incrementProgress : AllLevels a -> Data -> Data
incrementProgress allLevels data =
    { data | progress = Progress.incrementProgress allLevels data.currentLevel data.progress }


incrementMessageIndex : Data -> Data
incrementMessageIndex data =
    { data | successMessageIndex = data.successMessageIndex + 1 }
