module Views.Hub.World exposing
    ( currentLevelPointer
    , handleStartLevel
    , offsetStyles
    , renderIcon
    , renderLevel
    , renderNumber
    , renderWorld
    , renderWorlds
    , showInfo
    )

import Config.Levels exposing (allLevels)
import Css.Animation exposing (animation, ease, infinite)
import Css.Style as Style exposing (..)
import Data.Board.Types exposing (..)
import Data.InfoWindow as InfoWindow
import Data.Level.Progress exposing (completedLevel, levelNumber, reachedLevel)
import Data.Level.Types exposing (..)
import Dict
import Helpers.Html exposing (emptyProperty)
import Helpers.Wave exposing (wave)
import Html exposing (..)
import Html.Attributes exposing (class, id)
import Html.Events exposing (onClick)
import Scenes.Hub.Types as Hub exposing (..)
import Scenes.Tutorial.Types exposing (TutorialConfig)
import Views.Icons.Triangle exposing (triangle)
import Views.Seed.All exposing (renderSeed)


renderWorlds : HubModel -> List (Html HubMsg)
renderWorlds model =
    allLevels
        |> Dict.toList
        |> List.reverse
        |> List.map (renderWorld model)


renderWorld : HubModel -> ( WorldNumber, WorldData TutorialConfig ) -> Html HubMsg
renderWorld model (( _, worldData ) as world) =
    div [ style [ backgroundColor worldData.background ], class "pa5 flex" ]
        [ div
            [ style [ width 300 ], class "center" ]
            (worldData.levels
                |> Dict.toList
                |> List.reverse
                |> List.map (renderLevel model world)
            )
        ]


renderLevel :
    HubModel
    -> ( WorldNumber, WorldData TutorialConfig )
    -> ( LevelNumber, LevelData TutorialConfig )
    -> Html HubMsg
renderLevel model ( world, worldData ) ( level, levelData ) =
    let
        ln =
            levelNumber allLevels ( world, level )

        hasReachedLevel =
            reachedLevel allLevels ( world, level ) model.shared.progress

        isCurrentLevel =
            ( world, level ) == model.shared.progress
    in
    div
        [ styles
            [ [ width 35
              , marginTop 50
              , marginBottom 50
              , color worldData.textColor
              ]
            , offsetStyles level
            ]
        , showInfo ( world, level ) model
        , class "tc pointer relative"
        , id <| "level-" ++ String.fromInt ln
        ]
        [ currentLevelPointer isCurrentLevel
        , renderIcon ( world, level ) worldData.seedType model
        , renderNumber ln hasReachedLevel worldData
        ]


currentLevelPointer : Bool -> Html msg
currentLevelPointer isCurrentLevel =
    if isCurrentLevel then
        div
            [ style
                [ top -30
                , animation "hover" 1500 [ ease, infinite ]
                ]
            , class "absolute left-0 right-0"
            ]
            [ triangle ]

    else
        span [] []


offsetStyles : Int -> List Style
offsetStyles levelNumber =
    wave
        { center = [ leftAuto, rightAuto ]
        , right = [ leftAuto ]
        , left = []
        }
        (levelNumber - 1)


renderNumber : Int -> Bool -> WorldData TutorialConfig -> Html HubMsg
renderNumber visibleLevelNumber hasReachedLevel worldData =
    if hasReachedLevel then
        div
            [ style
                [ backgroundColor worldData.textBackgroundColor
                , marginTop 10
                , width 25
                , height 25
                ]
            , class "br-100 center flex justify-center items-center"
            ]
            [ p [ style [ color worldData.textCompleteColor ], class "f6" ] [ text <| String.fromInt visibleLevelNumber ] ]

    else
        p [ style [ color worldData.textColor ] ] [ text <| String.fromInt visibleLevelNumber ]


showInfo : Progress -> HubModel -> Attribute HubMsg
showInfo currentLevel model =
    if reachedLevel allLevels currentLevel model.shared.progress && InfoWindow.isHidden model.infoWindow then
        onClick <| ShowLevelInfo currentLevel

    else
        emptyProperty


handleStartLevel : Progress -> HubModel -> Attribute HubMsg
handleStartLevel currentLevel model =
    if reachedLevel allLevels currentLevel model.shared.progress then
        onClick <| StartLevel currentLevel

    else
        emptyProperty


renderIcon : ( WorldNumber, LevelNumber ) -> SeedType -> HubModel -> Html msg
renderIcon currentLevel seedType model =
    if completedLevel allLevels currentLevel model.shared.progress then
        renderSeed seedType

    else
        renderSeed GreyedOut
