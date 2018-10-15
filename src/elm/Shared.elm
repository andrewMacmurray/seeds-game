module Shared exposing
    ( Background(..)
    , Data
    , Window
    , decrementLife
    , generateBackground
    , hideLoadingScreen
    , incrementMessageIndex
    , incrementProgress
    , setCurrentLevel
    , setWindow
    , showLoadingScreen
    , updateLives
    )

import Data.Level.Progress as Progress
import Data.Level.Types exposing (AllLevels, Progress)
import Data.Lives as Lives exposing (Lives)
import Random
import Time


type alias Data =
    { window : Window
    , loadingScreen : Maybe Background
    , progress : Progress
    , currentLevel : Maybe Progress
    , successMessageIndex : Int
    , lives : Lives
    }


setCurrentLevel : Maybe Progress -> Data -> Data
setCurrentLevel level data =
    { data | currentLevel = level }


hideLoadingScreen : Data -> Data
hideLoadingScreen data =
    { data | loadingScreen = Nothing }


incrementProgress : AllLevels a -> Data -> Data
incrementProgress allLevels data =
    { data | progress = Progress.incrementProgress allLevels data.currentLevel data.progress }


incrementMessageIndex : Data -> Data
incrementMessageIndex data =
    { data | successMessageIndex = data.successMessageIndex + 1 }


updateLives : Time.Posix -> Data -> Data
updateLives now data =
    { data | lives = Lives.update now data.lives }


decrementLife : Data -> Data
decrementLife data =
    { data | lives = Lives.decrement data.lives }



-- Window


type alias Window =
    { width : Int
    , height : Int
    }


setWindow : Int -> Int -> Data -> Data
setWindow width height data =
    { data | window = Window width height }



-- Loading Screen


type Background
    = Orange
    | Blue


showLoadingScreen : Background -> Data -> Data
showLoadingScreen background data =
    { data | loadingScreen = Just background }


generateBackground : (Background -> msg) -> Cmd msg
generateBackground msg =
    Random.generate msg <| Random.uniform Orange [ Blue ]
