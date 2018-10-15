module Views.Loading exposing (loadingScreen)

import Config.Levels exposing (allLevels)
import Css.Color exposing (gold, rainBlue)
import Css.Style exposing (Style, backgroundColor, classes, empty, style, width)
import Css.Transition exposing (transitionAll)
import Data.Level.Progress exposing (currentLevelSeedType)
import Html exposing (..)
import Html.Attributes exposing (class)
import Shared exposing (Background(..))
import Types exposing (..)
import Views.Seed.All exposing (renderSeed)


loadingScreen : Shared.Data -> Html msg
loadingScreen model =
    div
        [ classes
            [ "w-100 h-100 fixed z-999 top-0 left-0 flex items-center justify-center"
            , transitionClasses model
            ]
        , style
            [ backgroundStyle model.loadingScreen
            , transitionAll 600 []
            ]
        ]
        [ div [ style [ width 50 ] ]
            [ renderSeed <| currentLevelSeedType allLevels model.currentLevel model.progress
            ]
        ]


backgroundStyle : Maybe Background -> Style
backgroundStyle sceneTransition =
    sceneTransition
        |> Maybe.map (loadingScreenColor >> backgroundColor)
        |> Maybe.withDefault empty


loadingScreenColor : Background -> String
loadingScreenColor bg =
    case bg of
        Blue ->
            rainBlue

        Orange ->
            gold


transitionClasses : Shared.Data -> String
transitionClasses model =
    case model.loadingScreen of
        Just _ ->
            "o-100"

        Nothing ->
            "o-0 touch-disabled"
