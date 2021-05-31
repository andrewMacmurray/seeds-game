module View.LoadingScreen exposing
    ( LoadingScreen
    , generate
    , hidden
    , view
    )

import Config.World as Worlds
import Css.Color exposing (gold, rainBlue)
import Css.Style as Style exposing (Style, classes, style, width)
import Css.Transition exposing (easeInOut, transitionAll)
import Html exposing (..)
import Level.Progress as Progress exposing (Progress)
import Random
import Seed exposing (Seed)
import View.Seed as Seed



-- Loading Screen


type alias Model model =
    { model
        | loadingScreen : LoadingScreen
        , progress : Progress
    }


type LoadingScreen
    = Hidden
    | Blue
    | Orange



-- Construct


hidden : LoadingScreen
hidden =
    Hidden



-- Generate


generate : (LoadingScreen -> msg) -> Cmd msg
generate msg =
    Random.uniform Blue [ Orange ] |> Random.generate msg



-- View


view : Model model -> Html msg
view model =
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
            [ Seed.view <| seedFromProgress model.progress
            ]
        ]


seedFromProgress : Progress -> Seed
seedFromProgress progress =
    Progress.currentLevelSeedType Worlds.all progress
        |> Maybe.withDefault (reachedLevelSeedType progress)


reachedLevelSeedType : Progress -> Seed
reachedLevelSeedType =
    Progress.reachedLevelSeedType Worlds.all


backgroundStyle : LoadingScreen -> Style
backgroundStyle screen =
    case screen of
        Blue ->
            Style.backgroundColor rainBlue

        Orange ->
            Style.backgroundColor gold

        Hidden ->
            Style.none


transitionClasses : Model model -> String
transitionClasses model =
    case model.loadingScreen of
        Hidden ->
            "o-0 touch-disabled"

        _ ->
            "o-100"
