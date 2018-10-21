module Shared exposing
    ( Background(..)
    , Data
    , Window
    , clearCurrentLevel
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

import Data.Levels as Levels
import Data.Lives as Lives exposing (Lives)
import Random
import Time


type alias Data =
    { window : Window
    , loadingScreen : Maybe Background
    , progress : Levels.Key
    , currentLevel : Maybe Levels.Key
    , successMessageIndex : Int
    , lives : Lives
    }


setCurrentLevel : Levels.Key -> Data -> Data
setCurrentLevel level data =
    { data | currentLevel = Just level }


clearCurrentLevel : Data -> Data
clearCurrentLevel data =
    { data | currentLevel = Nothing }


hideLoadingScreen : Data -> Data
hideLoadingScreen data =
    { data | loadingScreen = Nothing }


incrementProgress : Levels.Worlds -> Data -> Data
incrementProgress allLevels data =
    { data | progress = handleNextLevel allLevels data.progress data.currentLevel }


incrementMessageIndex : Data -> Data
incrementMessageIndex data =
    { data | successMessageIndex = data.successMessageIndex + 1 }


updateLives : Time.Posix -> Data -> Data
updateLives now data =
    { data | lives = Lives.update now data.lives }


decrementLife : Data -> Data
decrementLife data =
    { data | lives = Lives.decrement data.lives }



-- Progress


handleNextLevel : Levels.Worlds -> Levels.Key -> Maybe Levels.Key -> Levels.Key
handleNextLevel allLevels progress currentLevel =
    case currentLevel of
        Nothing ->
            progress

        Just current ->
            if not <| Levels.completed current progress then
                Levels.next allLevels current

            else
                progress



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
