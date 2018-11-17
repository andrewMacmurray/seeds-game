module Shared exposing
    ( Background(..)
    , Data
    , clearCurrentLevel
    , closeMenu
    , decrementLife
    , generateBackground
    , hideLoadingScreen
    , incrementMessageIndex
    , incrementProgress
    , openMenu
    , setCurrentLevel
    , setWindow
    , showLoadingScreen
    , updateLives
    )

import Data.Levels as Levels
import Data.Lives as Lives exposing (Lives)
import Data.Progress as Progress exposing (Progress)
import Data.Window exposing (Window)
import Random
import Time


type alias Data =
    { window : Window
    , loadingScreen : Maybe Background
    , progress : Progress
    , lives : Lives
    , successMessageIndex : Int
    , menuOpen : Bool
    }


setCurrentLevel : Levels.Key -> Data -> Data
setCurrentLevel level data =
    { data | progress = Progress.setCurrentLevel level data.progress }


clearCurrentLevel : Data -> Data
clearCurrentLevel data =
    { data | progress = Progress.clearCurrentLevel data.progress }


hideLoadingScreen : Data -> Data
hideLoadingScreen data =
    { data | loadingScreen = Nothing }


openMenu : Data -> Data
openMenu data =
    { data | menuOpen = True }


closeMenu : Data -> Data
closeMenu data =
    { data | menuOpen = False }


incrementProgress : Levels.Worlds -> Data -> Data
incrementProgress allLevels data =
    { data | progress = Progress.handleIncrement allLevels data.progress }


incrementMessageIndex : Data -> Data
incrementMessageIndex data =
    { data | successMessageIndex = data.successMessageIndex + 1 }


updateLives : Time.Posix -> Data -> Data
updateLives now data =
    { data | lives = Lives.update now data.lives }


decrementLife : Data -> Data
decrementLife data =
    { data | lives = Lives.decrement data.lives }


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
