module Views.Hub.InfoWindow exposing (..)

import Config.Levels exposing (allLevels)
import Config.Color exposing (..)
import Data.InfoWindow exposing (..)
import Data.Hub.Progress exposing (getLevelConfig, getLevelNumber)
import Data.Level.Score exposing (collectable, scoreTileTypes)
import Helpers.Html exposing (emptyProperty)
import Helpers.Style exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Scenes.Hub.Types as Hub exposing (..)
import Scenes.Level.Types exposing (SeedType, TargetScore(..), TileConfig, TileSetting, TileType, TileType(..))
import Views.InfoWindow exposing (infoContainer)
import Views.Seed.All exposing (renderSeed)


info : Hub.Model -> Html Hub.Msg
info model =
    case model.infoWindow of
        Hidden ->
            span [] []

        Visible progress ->
            let
                content =
                    getLevelConfig progress |> infoContent progress
            in
                infoContainer model.infoWindow <|
                    div [ onClick <| StartLevel progress ] content

        Hiding progress ->
            let
                content =
                    getLevelConfig progress |> infoContent progress
            in
                infoContainer model.infoWindow <|
                    div [] content


infoContent : Progress -> ( WorldData, LevelData ) -> List (Html msg)
infoContent ( world, level ) ( worldData, levelData ) =
    let
        levelText =
            allLevels
                |> getLevelNumber ( world, level )
                |> toString
                |> (++) "Level "
    in
        [ p [ class "f5 tracked", style [ marginTop 20 ] ] [ text levelText ]
        , infoIcons levelData worldData.seedType
        , p
            [ class "tracked-mega pv2 ph3 dib br4"
            , style [ backgroundColor gold, marginBottom 20, marginTop 15 ]
            ]
            [ text "PLAY" ]
        ]


infoIcons : LevelData -> SeedType -> Html msg
infoIcons levelData seedType =
    levelData.tileSettings
        |> List.filter collectable
        |> List.map renderIcon
        |> infoIconsContainer


infoIconsContainer : List (Html msg) -> Html msg
infoIconsContainer =
    div [ class "flex justify-center items-end", style [ marginTop 25, marginBottom 15 ] ]


renderIcon : TileSetting -> Html msg
renderIcon { targetScore, tileType } =
    let
        tileIcon =
            case tileType of
                Rain ->
                    renderWeather lightBlue

                Sun ->
                    renderWeather orange

                Seed seedType ->
                    div [ style [ widthStyle 35, heightStyle 53 ] ] [ renderSeed seedType ]

                _ ->
                    span [] []
    in
        div [ class "dib mh3" ]
            [ div [ class "center flex flex-column" ]
                [ tileIcon
                , renderTargetScore targetScore
                ]
            ]


renderTargetScore : Maybe TargetScore -> Html msg
renderTargetScore ts =
    case ts of
        Just (TargetScore t) ->
            p [ class "f6 mb0", style [ marginTop 10 ] ] [ text <| toString t ]

        Nothing ->
            span [] []


renderWeather : String -> Html msg
renderWeather color =
    div
        [ style
            [ widthStyle 25
            , heightStyle 25
            , marginLeft 2.5
            , marginRight 2.5
            , marginBottom 5
            , background color
            ]
        , classes [ "br-100" ]
        ]
        []


handleHideInfo : Hub.Model -> Attribute Hub.Msg
handleHideInfo model =
    case model.infoWindow of
        Visible _ ->
            onClick HideInfo

        _ ->
            emptyProperty
