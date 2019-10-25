module Views.Loading exposing (loadingScreen)

import Board.Tile as Tile exposing (SeedType(..))
import Config.Worlds as Worlds
import Context exposing (Background(..), Context)
import Css.Color exposing (gold, rainBlue)
import Css.Style exposing (Style, backgroundColor, classes, none, style, width)
import Css.Transition exposing (easeInOut, transitionAll)
import Html exposing (..)
import Level.Progress as Progress exposing (Progress)
import Views.Seed.All exposing (renderSeed)


loadingScreen : Context -> Html msg
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
            [ renderSeed <| seedType model.progress
            ]
        ]


seedType : Progress -> Tile.SeedType
seedType progress =
    Progress.currentLevelSeedType Worlds.all progress
        |> Maybe.withDefault (reachedLevelSeedType progress)


reachedLevelSeedType : Progress -> Tile.SeedType
reachedLevelSeedType progress =
    Progress.reachedLevelSeedType Worlds.all progress
        |> Maybe.withDefault Sunflower


backgroundStyle : Maybe Background -> Style
backgroundStyle sceneTransition =
    sceneTransition
        |> Maybe.map (loadingScreenColor >> backgroundColor)
        |> Maybe.withDefault none


loadingScreenColor : Background -> String
loadingScreenColor bg =
    case bg of
        Blue ->
            rainBlue

        Orange ->
            gold


transitionClasses : Context -> String
transitionClasses model =
    case model.loadingScreen of
        Just _ ->
            "o-100"

        Nothing ->
            "o-0 touch-disabled"
