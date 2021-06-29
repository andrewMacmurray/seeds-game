module View.LoadingScreen exposing
    ( LoadingScreen
    , generate
    , hidden
    , view
    )

import Element exposing (..)
import Element.Background as Background
import Element.Palette as Palette
import Element.Seed as Seed
import Element.Transition as Transition
import Game.Config.World as Worlds
import Game.Level.Progress as Progress exposing (Progress)
import Random
import Seed exposing (Seed)
import Utils.Element as Element



-- Loading Screen


type alias Model =
    { loadingScreen : LoadingScreen
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


view : Model -> Element msg
view model =
    el
        [ width fill
        , height fill
        , Background.color (toBackground model)
        , Element.disableIf (isHidden model)
        , Transition.background 500
        ]
        (viewSeed model)


viewSeed : Model -> Element msg
viewSeed model =
    el
        [ centerY
        , centerX
        , Transition.alpha 500
        , Element.visibleIf (isVisible model)
        ]
        (Seed.view Seed.large (seedFromProgress model.progress))


isVisible : Model -> Bool
isVisible =
    isHidden >> not


isHidden : Model -> Bool
isHidden model =
    case model.loadingScreen of
        Hidden ->
            True

        _ ->
            False


toBackground : Model -> Color
toBackground model =
    case model.loadingScreen of
        Blue ->
            Palette.blue5

        Orange ->
            Palette.gold

        Hidden ->
            Palette.transparent


seedFromProgress : Progress -> Seed
seedFromProgress progress =
    progress
        |> Progress.currentLevelSeedType Worlds.all
        |> Maybe.withDefault (reachedLevelSeedType progress)


reachedLevelSeedType : Progress -> Seed
reachedLevelSeedType =
    Progress.reachedLevelSeedType Worlds.all
