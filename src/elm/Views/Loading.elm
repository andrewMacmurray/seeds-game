module Views.Loading exposing (..)

import Config.Color exposing (gold, rainBlue)
import Config.Levels exposing (allLevels)
import Data.Background exposing (..)
import Data.Level.Progress exposing (currentLevelSeedType)
import Helpers.Css.Style exposing (Style, backgroundColor, classes, emptyStyle, widthStyle)
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
            [ loadingScreenBackground model.loadingScreen
            , easeAll 500
            ]
        ]
        [ div [ style [ widthStyle 50 ] ]
            [ renderSeed <| currentLevelSeedType allLevels model.currentLevel model.progress
            ]
        ]


loadingScreenBackground : Maybe Background -> Style
loadingScreenBackground sceneTransition =
    sceneTransition
        |> Maybe.map (loadingScreenColor >> backgroundColor)
        |> Maybe.withDefault emptyStyle


loadingScreenColor : Background -> String
loadingScreenColor bg =
    case bg of
        Blue ->
            rainBlue

        Orange ->
            gold


transitionClasses : Model -> String
transitionClasses model =
    case model.loadingScreen of
        Just _ ->
            "o-100"

        Nothing ->
            "o-0 touch-disabled"
