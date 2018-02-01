module Views.Hub.World exposing (..)

import Data.Hub.Progress exposing (completedLevel, getLevelNumber, reachedLevel)
import Dict
import Helpers.Html exposing (emptyProperty)
import Helpers.Style exposing (backgroundColor, color, heightStyle, marginBottom, marginTop, widthStyle)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Config.Levels exposing (allLevels)
import Scenes.Hub.Types as Hub exposing (..)
import Scenes.Level.Types exposing (SeedType(..))
import Views.Seed.All exposing (renderSeed)
import Types exposing (..)


renderWorlds : Hub.Model -> List (Html Hub.Msg)
renderWorlds model =
    allLevels
        |> Dict.toList
        |> List.reverse
        |> List.map (renderWorld model)


renderWorld : Hub.Model -> ( WorldNumber, WorldData ) -> Html Hub.Msg
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


renderLevel : Hub.Model -> ( WorldNumber, WorldData ) -> ( LevelNumber, LevelData ) -> Html Hub.Msg
renderLevel model ( world, worldData ) ( level, levelData ) =
    let
        levelNumber =
            getLevelNumber ( world, level ) allLevels |> toString
    in
        div
            [ showInfo ( world, level ) model
            , class "tc center pointer"
            , id <| "level-" ++ levelNumber
            , style
                [ widthStyle 35
                , marginTop 50
                , marginBottom 50
                , color worldData.textColor
                ]
            ]
            [ renderIcon ( world, level ) worldData.seedType model
            , renderNumber levelNumber ( world, level ) worldData model
            ]


renderNumber : String -> ( WorldNumber, LevelNumber ) -> WorldData -> Hub.Model -> Html Hub.Msg
renderNumber visibleLevelNumber currentLevel worldData model =
    if reachedLevel currentLevel model then
        div
            [ class "br-100 center flex justify-center items-center"
            , style
                [ backgroundColor worldData.textBackgroundColor
                , marginTop 10
                , widthStyle 25
                , heightStyle 25
                ]
            ]
            [ p [ style [ color worldData.textCompleteColor ], class "f6" ] [ text visibleLevelNumber ] ]
    else
        p [ style [ color worldData.textColor ] ] [ text visibleLevelNumber ]


showInfo : LevelProgress -> Hub.Model -> Attribute Hub.Msg
showInfo currentLevel model =
    if reachedLevel currentLevel model && model.infoWindow == Hidden then
        onClick <| ShowInfo currentLevel
    else
        emptyProperty


handleStartLevel : LevelProgress -> Hub.Model -> Attribute Hub.Msg
handleStartLevel currentLevel model =
    if reachedLevel currentLevel model then
        onClick <| StartLevel currentLevel
    else
        emptyProperty


renderIcon : ( WorldNumber, LevelNumber ) -> SeedType -> Hub.Model -> Html Hub.Msg
renderIcon currentLevel seedType model =
    if completedLevel currentLevel model then
        renderSeed seedType
    else
        renderSeed GreyedOut
