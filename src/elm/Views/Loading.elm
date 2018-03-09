module Views.Loading exposing (..)

import Config.Color exposing (gold, rainBlue)
import Data.Hub.Progress exposing (currentLevelSeedType)
import Helpers.Style exposing (backgroundColor, classes, transitionStyle, widthStyle)
import Html exposing (..)
import Html.Attributes exposing (..)
import Scenes.Hub.Types as Hub exposing (..)
import Views.Seed.All exposing (renderSeed)


loadingScreen : Hub.Model -> Html msg
loadingScreen model =
    div
        [ classes
            [ "w-100 h-100 fixed z-999 top-0 left-0 flex items-center justify-center"
            , transitionClasses model
            ]
        , style
            [ backgroundColor <| loadingBackground model.transitionBackground
            , transitionStyle "0.5s ease"
            ]
        ]
        [ div [ style [ widthStyle 50 ] ] [ renderSeed <| currentLevelSeedType model ] ]


loadingBackground : TransitionBackground -> String
loadingBackground bg =
    case bg of
        Blue ->
            rainBlue

        Orange ->
            gold


transitionClasses : Hub.Model -> String
transitionClasses model =
    if model.sceneTransition then
        "o-100"
    else
        "o-0 touch-disabled"
