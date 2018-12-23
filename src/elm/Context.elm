module Context exposing
    ( Background(..)
    , Context
    , Menu(..)
    , cacheCurrentLives
    , clearCurrentLevel
    , closeMenu
    , decrementLife
    , disableMenu
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
import Ports exposing (cacheLives)
import Random
import Time


type alias Context =
    { window : Window
    , loadingScreen : Maybe Background
    , progress : Progress
    , lives : Lives
    , successMessageIndex : Int
    , menu : Menu
    }


incrementMessageIndex : Context -> Context
incrementMessageIndex context =
    { context | successMessageIndex = context.successMessageIndex + 1 }


setWindow : Int -> Int -> Context -> Context
setWindow width height context =
    { context | window = Window width height }



-- Progress


setCurrentLevel : Levels.Key -> Context -> Context
setCurrentLevel level context =
    { context | progress = Progress.setCurrentLevel level context.progress }


clearCurrentLevel : Context -> Context
clearCurrentLevel context =
    { context | progress = Progress.clearCurrentLevel context.progress }


incrementProgress : Levels.Worlds -> Context -> Context
incrementProgress allLevels context =
    { context | progress = Progress.handleIncrement allLevels context.progress }



-- Lives


updateLives : Time.Posix -> Context -> Context
updateLives now context =
    { context | lives = Lives.update now context.lives }


decrementLife : Context -> Context
decrementLife context =
    { context | lives = Lives.decrement context.lives }


cacheCurrentLives : Context -> Cmd msg
cacheCurrentLives context =
    context.lives
        |> Lives.toCache
        |> cacheLives



-- Menu


type Menu
    = Open
    | Closed
    | Disabled


openMenu : Context -> Context
openMenu context =
    { context | menu = Open }


closeMenu : Context -> Context
closeMenu context =
    { context | menu = Closed }


disableMenu : Context -> Context
disableMenu context =
    { context | menu = Disabled }



-- Loading Screen


type Background
    = Orange
    | Blue


showLoadingScreen : Background -> Context -> Context
showLoadingScreen background context =
    { context | loadingScreen = Just background }


hideLoadingScreen : Context -> Context
hideLoadingScreen context =
    { context | loadingScreen = Nothing }


generateBackground : (Background -> msg) -> Cmd msg
generateBackground msg =
    Random.generate msg <| Random.uniform Orange [ Blue ]
