module Views.Hub.World exposing (..)

import Data.Hub.Progress exposing (completedLevel, getLevelNumber, reachedLevel)
import Dict
import Helpers.Html exposing (emptyProperty)
import Helpers.Style exposing (backgroundColor, color, heightStyle, marginBottom, marginTop, widthStyle)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Model as Main exposing (Msg(..))
import Scenes.Hub.Model as Hub exposing (Msg(..))
import Data.Level.Types exposing (SeedType(..))
import Data.Hub.Types exposing (..)
import Views.Seed.All exposing (renderSeed)


renderWorlds : Hub.Model -> List (Html Main.Msg)
renderWorlds model =
    model.hubData
        |> Dict.toList
        |> List.reverse
        |> List.map (renderWorld model)


renderWorld : Hub.Model -> ( WorldNumber, WorldData ) -> Html Main.Msg
renderWorld model (( _, worldData ) as world) =
    div [ style [ backgroundColor worldData.background ], class "pa5 flex" ]
        [ div
            [ style [ widthStyle 300 ], class "center" ]
            (worldData.levels
                |> Dict.toList
                |> List.reverse
                |> List.map (renderLevel model world)
            )
        ]


renderLevel : Hub.Model -> ( WorldNumber, WorldData ) -> ( LevelNumber, LevelData ) -> Html Main.Msg
renderLevel model ( world, worldData ) ( level, levelData ) =
    let
        levelNumber =
            getLevelNumber ( world, level ) model.hubData |> toString
    in
        div
            [ showInfo ( world, level ) model
            , class "tc center pointer"
            , id <| "level-" ++ levelNumber
            , style
                [ widthStyle 40
                , marginTop 50
                , marginBottom 50
                , color worldData.textColor
                ]
            ]
            [ renderIcon ( world, level ) worldData.seedType model
            , renderNumber levelNumber ( world, level ) worldData model
            ]


renderNumber : String -> ( WorldNumber, LevelNumber ) -> WorldData -> Hub.Model -> Html Main.Msg
renderNumber visibleLevelNumber currentLevel worldData model =
    if reachedLevel currentLevel model then
        div
            [ class "br-100 center flex justify-center items-center"
            , style
                [ backgroundColor worldData.textBackgroundColor
                , marginTop 10
                , widthStyle 30
                , heightStyle 30
                ]
            ]
            [ p [ style [ color worldData.textCompleteColor ] ] [ text visibleLevelNumber ] ]
    else
        p [ style [ color worldData.textColor ] ] [ text visibleLevelNumber ]


showInfo : LevelProgress -> Hub.Model -> Attribute Main.Msg
showInfo currentLevel model =
    if reachedLevel currentLevel model then
        onClick <| HubMsg <| ShowInfo currentLevel
    else
        emptyProperty


handleStartLevel : LevelProgress -> Hub.Model -> Attribute Main.Msg
handleStartLevel currentLevel model =
    if reachedLevel currentLevel model then
        onClick <| StartLevel currentLevel
    else
        emptyProperty


renderIcon : ( WorldNumber, LevelNumber ) -> SeedType -> Hub.Model -> Html Main.Msg
renderIcon currentLevel seedType model =
    if completedLevel currentLevel model then
        renderSeed seedType
    else
        renderSeed GreyedOut
