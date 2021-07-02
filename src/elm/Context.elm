module Context exposing
    ( Context
    , clearCurrentLevel
    , closeMenu
    , decrementLife
    , disableMenu
    , hideLoadingScreen
    , incrementProgress
    , nextMessage
    , openMenu
    , saveCurrentLives
    , setCurrentLevel
    , setWindow
    , showLoadingScreen
    , updateLives
    )

import Element.Loading as Loading
import Element.Menu as Menu
import Game.Config.Level as Level
import Game.Level.Progress as Progress exposing (Progress)
import Game.Lives as Lives exposing (Lives)
import Time
import Window exposing (Window)



-- Context


type alias Context =
    { window : Window
    , loading : Loading.Screen
    , progress : Progress
    , lives : Lives
    , successMessageIndex : Int
    , menu : Menu.State
    }


nextMessage : Context -> Context
nextMessage context =
    { context | successMessageIndex = context.successMessageIndex + 1 }


setWindow : Int -> Int -> Context -> Context
setWindow width height context =
    { context | window = Window width height }



-- Progress


setCurrentLevel : Level.Id -> Context -> Context
setCurrentLevel level context =
    { context | progress = Progress.setCurrentLevel level context.progress }


clearCurrentLevel : Context -> Context
clearCurrentLevel context =
    { context | progress = Progress.clearCurrentLevel context.progress }


incrementProgress : Level.Worlds -> Context -> Context
incrementProgress allLevels context =
    { context | progress = Progress.handleIncrement allLevels context.progress }



-- Lives


updateLives : Time.Posix -> Context -> Context
updateLives now context =
    { context | lives = Lives.update now context.lives }


decrementLife : Context -> Context
decrementLife context =
    { context | lives = Lives.decrement context.lives }


saveCurrentLives : Context -> Cmd msg
saveCurrentLives context =
    Lives.save context.lives


openMenu : Context -> Context
openMenu context =
    { context | menu = Menu.open }


closeMenu : Context -> Context
closeMenu context =
    { context | menu = Menu.closed }


disableMenu : Context -> Context
disableMenu context =
    { context | menu = Menu.disabled }



-- Loading Screen


showLoadingScreen : Loading.Screen -> Context -> Context
showLoadingScreen loading context =
    { context | loading = loading }


hideLoadingScreen : Context -> Context
hideLoadingScreen context =
    { context | loading = Loading.hidden }
