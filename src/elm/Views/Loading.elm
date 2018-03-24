module Views.Loading exposing (..)

import Config.Color exposing (gold, rainBlue)
import Config.Levels exposing (allLevels)
import Data.Background exposing (..)
import Data.Level.Progress exposing (currentLevelSeedType)
import Helpers.Css.Style exposing (backgroundColor, classes, widthStyle)
import Helpers.Css.Transition exposing (easeAll)
import Html exposing (..)
import Html.Attributes exposing (..)
import Types exposing (..)
import Views.Seed.All exposing (renderSeed)


loadingScreen : Model -> Html msg
loadingScreen model =
    div
        [ classes
            [ "w-100 h-100 fixed z-999 top-0 left-0 flex items-center justify-center"
            , transitionClasses model
            ]
        , style
            [ backgroundColor <| loadingBackground model.transitionBackground
            , easeAll 500
            ]
        ]
        [ div [ style [ widthStyle 50 ] ]
            [ renderSeed <| currentLevelSeedType allLevels model.currentLevel model.progress
            ]
        ]


loadingBackground : Background -> String
loadingBackground bg =
    case bg of
        Blue ->
            rainBlue

        Orange ->
            gold


transitionClasses : Model -> String
transitionClasses model =
    if model.sceneTransition then
        "o-100"
    else
        "o-0 touch-disabled"
