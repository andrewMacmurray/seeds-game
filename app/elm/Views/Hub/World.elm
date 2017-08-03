module Views.Hub.World exposing (..)

import Data.Hub.Progress exposing (levelNumber, reachedLevel)
import Dict
import Helpers.Html exposing (emptyProperty)
import Helpers.Style exposing (backgroundColor, color, heightStyle, widthStyle)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Model exposing (..)
import Scenes.Level.Model exposing (SeedType(..))
import Views.Seed.All exposing (renderSeed)


renderWorlds : Model -> List (Html Msg)
renderWorlds model =
    model.hubData
        |> Dict.toList
        |> List.reverse
        |> List.map (renderWorld model)


renderWorld : Model -> ( WorldNumber, WorldData ) -> Html Msg
renderWorld model (( _, worldData ) as world) =
    div [ style [ backgroundColor worldData.background ], class "pa5" ]
        [ div
            [ style [ widthStyle 300 ], class "center" ]
            (worldData.levels
                |> Dict.toList
                |> List.reverse
                |> List.map (renderLevel model world)
            )
        ]


renderLevel : Model -> ( WorldNumber, WorldData ) -> ( LevelNumber, LevelData ) -> Html Msg
renderLevel model ( world, worldData ) ( level, levelData ) =
    div
        [ handleStartLevel ( world, level ) levelData model
        , class "tc center pointer"
        , style
            [ widthStyle 40
            , color worldData.textColor
            ]
        ]
        [ renderIcon ( world, level ) worldData.seedType model
        , p [] [ text <| toString <| levelNumber ( world, level ) model.hubData ]
        ]


handleStartLevel : ( WorldNumber, LevelNumber ) -> LevelData -> Model -> Attribute Msg
handleStartLevel currentLevel levelData model =
    if reachedLevel currentLevel model then
        onClick <| StartLevel currentLevel levelData
    else
        emptyProperty


renderIcon : ( WorldNumber, LevelNumber ) -> SeedType -> Model -> Html Msg
renderIcon currentLevel seedType model =
    if currentLevel == model.progress then
        renderSeed GreyedOut
    else if reachedLevel currentLevel model then
        renderSeed seedType
    else
        renderSeed GreyedOut
