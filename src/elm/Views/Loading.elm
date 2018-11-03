module Views.Loading exposing (loadingScreen)

import Css.Color exposing (gold, rainBlue)
import Css.Style exposing (Style, backgroundColor, classes, empty, style, width)
import Css.Transition exposing (easeInOut, transitionAll)
import Data.Board.Types exposing (SeedType(..))
import Data.Levels as Levels
import Data.Progress as Progress exposing (Progress)
import Html exposing (..)
import Html.Attributes exposing (class)
import Shared exposing (Background(..))
import Views.Seed.All exposing (renderSeed)
import Worlds


loadingScreen : Shared.Data -> Html msg
loadingScreen model =
    div
        [ classes
            [ "w-100 h-100 fixed z-999 top-0 left-0 flex items-center justify-center"
            , transitionClasses model
            ]
        , style
            [ backgroundStyle model.loadingScreen
            , transitionAll 500 [ easeInOut ]
            ]
        ]
        [ div [ style [ width 50 ] ]
            [ renderSeed <| currentLevelSeedType model.progress
            ]
        ]


currentLevelSeedType : Progress -> SeedType
currentLevelSeedType progress =
    Progress.currentLevelSeedType Worlds.all progress
        |> Maybe.withDefault (currentProgressSeedType progress)


currentProgressSeedType : Progress -> SeedType
currentProgressSeedType progress =
    Progress.seedType Worlds.all progress
        |> Maybe.withDefault Sunflower


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
