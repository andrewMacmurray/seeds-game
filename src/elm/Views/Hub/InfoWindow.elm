module Views.Hub.InfoWindow exposing
    ( handleHideInfo
    , info
    , infoContent
    , infoIcons
    , infoIconsContainer
    , renderIcon
    , renderTargetScore
    , renderWeather
    )

import Config.Levels exposing (allLevels, getLevelConfig, getLevelNumber)
import Css.Color exposing (..)
import Css.Style as Style exposing (..)
import Data.Board.Score exposing (collectable, scoreTileTypes)
import Data.Board.Types exposing (..)
import Data.InfoWindow exposing (..)
import Data.Level.Progress exposing (..)
import Data.Level.Types exposing (..)
import Helpers.Html exposing (emptyProperty)
import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Scenes.Hub.Types as Hub exposing (HubModel, HubMsg(..))
import Views.InfoWindow exposing (infoContainer)
import Views.Seed.All exposing (renderSeed)


info : HubModel -> Html HubMsg
info { infoWindow } =
    let
        progress =
            val infoWindow |> Maybe.withDefault ( 1, 1 )

        content =
            getLevelConfig progress |> infoContent progress
    in
    if isHidden infoWindow then
        span [] []

    else if isVisible infoWindow then
        infoContainer infoWindow <| div [ onClick <| StartLevel progress ] content

    else
        infoContainer infoWindow <| div [] content


infoContent : Progress -> CurrentLevelConfig tutorialConfig -> List (Html msg)
infoContent ( world, level ) ( worldData, levelData ) =
    let
        levelText =
            getLevelNumber ( world, level )
                |> String.fromInt
                |> (++) "Level "
    in
    [ p [ style [ marginTop 20 ], class "f5 tracked" ] [ text levelText ]
    , infoIcons levelData worldData.seedType
    , p
        [ style
            [ backgroundColor gold
            , marginBottom 20
            , marginTop 15
            ]
        , class "tracked-mega pv2 ph3 dib br4"
        ]
        [ text "PLAY" ]
    ]


infoIcons : LevelData tutorialConfig -> SeedType -> Html msg
infoIcons levelData seedType =
    levelData.tileSettings
        |> List.filter collectable
        |> List.map renderIcon
        |> infoIconsContainer


infoIconsContainer : List (Html msg) -> Html msg
infoIconsContainer =
    div
        [ style
            [ marginTop 25
            , marginBottom 15
            ]
        , class "flex justify-center items-end"
        ]


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
                    div [ style [ width 35, height 53 ] ] [ renderSeed seedType ]

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
            p [ style [ marginTop 10 ], class "f6 mb0" ] [ text <| String.fromInt t ]

        Nothing ->
            span [] []


renderWeather : String -> Html msg
renderWeather color =
    div
        [ style
            [ width 25
            , height 25
            , marginLeft 2.5
            , marginRight 2.5
            , marginBottom 5
            , background color
            ]
        , classes [ "br-100" ]
        ]
        []


handleHideInfo : HubModel -> Attribute HubMsg
handleHideInfo model =
    if isVisible model.infoWindow then
        onClick HideLevelInfo

    else
        emptyProperty
