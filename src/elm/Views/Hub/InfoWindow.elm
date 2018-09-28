module Views.Hub.InfoWindow exposing (handleHideInfo, info, infoContent, infoIcons, infoIconsContainer, renderIcon, renderTargetScore, renderWeather)

import Config.Color exposing (..)
import Config.Levels exposing (allLevels)
import Data.Board.Score exposing (collectable, scoreTileTypes)
import Data.Board.Types exposing (..)
import Data.InfoWindow exposing (..)
import Data.Level.Progress exposing (..)
import Data.Level.Types exposing (..)
import Helpers.Css.Style exposing (..)
import Helpers.Html exposing (emptyProperty)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Scenes.Hub.Types as Hub exposing (HubModel, HubMsg(..))
import State exposing (getLevelConfig)
import Types exposing (Msg(..))
import Views.InfoWindow exposing (infoContainer)
import Views.Seed.All exposing (renderSeed)


info : HubModel model -> Html Msg
info { hubInfoWindow } =
    let
        progress =
            val hubInfoWindow |> Maybe.withDefault ( 1, 1 )

        content =
            getLevelConfig progress |> infoContent progress
    in
    if isHidden hubInfoWindow then
        span [] []

    else if isVisible hubInfoWindow then
        infoContainer hubInfoWindow <| div [ onClick <| StartLevel progress ] content

    else
        infoContainer hubInfoWindow <| div [] content


infoContent : Progress -> CurrentLevelConfig tutorialConfig -> List (Html msg)
infoContent ( world, level ) ( worldData, levelData ) =
    let
        levelText =
            allLevels
                |> getLevelNumber ( world, level )
                |> String.fromInt
                |> (++) "Level "
    in
    [ p [ class "f5 tracked", styleAttr (marginTop 20) ] [ text levelText ]
    , infoIcons levelData worldData.seedType
    , p
        [ class "tracked-mega pv2 ph3 dib br4"
        , styleAttr (backgroundColor gold)
        , styleAttr (marginBottom 20)
        , styleAttr (marginTop 15)
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
    div [ class "flex justify-center items-end", styleAttr (marginTop 25), styleAttr (marginBottom 15) ]


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
                    div [ styleAttr (widthStyle 35), styleAttr (heightStyle 53) ] [ renderSeed seedType ]

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
            p [ class "f6 mb0", styleAttr (marginTop 10) ] [ text <| String.fromInt t ]

        Nothing ->
            span [] []


renderWeather : String -> Html msg
renderWeather color =
    div
        [ styleAttr (widthStyle 25)
        , styleAttr (heightStyle 25)
        , styleAttr (marginLeft 2.5)
        , styleAttr (marginRight 2.5)
        , styleAttr (marginBottom 5)
        , styleAttr (background color)
        , classes [ "br-100" ]
        ]
        []


handleHideInfo : HubModel model -> Attribute Msg
handleHideInfo model =
    if isVisible model.hubInfoWindow then
        onClick <| HubMsg HideLevelInfo

    else
        emptyProperty
