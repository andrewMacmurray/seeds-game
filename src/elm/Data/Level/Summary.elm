module Data.Level.Summary exposing (..)

import Config.Levels exposing (allLevels)
import Data2.Level.Score exposing (collectable)
import Data2.Level.Settings exposing (..)
import Data2.Tile exposing (SeedType, TileType, getSeedType)
import Dict exposing (Dict)
import Helpers.Dict exposing (insertWith, mapValues)
import Scenes.Tutorial.Types as Tutorial


percentComplete : TileType -> Progress -> Maybe Progress -> Float
percentComplete tileType ( w, l ) currentLevel =
    let
        target =
            totalTargetScoresForWorld w
                |> Maybe.andThen (Dict.get (toString tileType))

        current =
            currentTotalScoresForWorld ( w, l )
                |> Maybe.andThen (Dict.get (toString tileType))

        percent a b =
            (toFloat b / toFloat a) * 100
    in
        if worldComplete ( w, l ) currentLevel then
            100
        else
            Maybe.map2 percent target current
                |> Maybe.withDefault 0


primarySeedType : Progress -> Maybe Progress -> Maybe SeedType
primarySeedType progress currentLevel =
    if worldComplete progress currentLevel then
        currentLevel |> Maybe.andThen worldSeedType
    else
        worldSeedType progress


secondaryResourceTypes : Maybe Progress -> Maybe (List TileType)
secondaryResourceTypes currentLevel =
    currentLevel
        |> Maybe.andThen getWorld
        |> Maybe.map secondaryResourceTypes_


secondaryResourceTypes_ : WorldData tutorialConfig -> List TileType
secondaryResourceTypes_ { levels, seedType } =
    levels
        |> mapValues .tileSettings
        |> Dict.values
        |> List.concat
        |> List.filter collectable
        |> List.map .tileType
        |> List.filter (secondaryResource seedType)
        |> uniqueMembers


secondaryResource : SeedType -> TileType -> Bool
secondaryResource seedType tileType =
    case getSeedType tileType of
        Just seedType_ ->
            not <| seedType == seedType_

        Nothing ->
            True


uniqueMembers : List a -> List a
uniqueMembers =
    let
        accum a b =
            if List.member a b then
                b
            else
                a :: b
    in
        List.foldr accum []


worldComplete : Progress -> Maybe Progress -> Bool
worldComplete progress curr =
    case curr of
        Just ( w, _ ) ->
            progress == ( w + 1, 1 )

        Nothing ->
            False


worldSeedType : Progress -> Maybe SeedType
worldSeedType =
    getWorld >> Maybe.map .seedType


currentTotalScoresForWorld : Progress -> Maybe (Dict String Int)
currentTotalScoresForWorld (( worldNumber, levelNumber ) as progress) =
    getWorld progress |> Maybe.map (scoresAtLevel levelNumber)


getWorld : Progress -> Maybe (WorldData Tutorial.Config)
getWorld ( w, _ ) =
    Dict.get w allLevels


totalTargetScoresForWorld : Int -> Maybe (Dict String Int)
totalTargetScoresForWorld worldNumber =
    allLevels
        |> Dict.get worldNumber
        |> Maybe.map scoresForWorld


scoresAtLevel : Int -> WorldData tutorialConfig -> Dict String Int
scoresAtLevel level { levels } =
    levels
        |> mapValues .tileSettings
        |> Dict.filter (\k _ -> k < level)
        |> Dict.values
        |> List.concat
        |> totalScoresDict


scoresForWorld : WorldData tutorialConfig -> Dict String Int
scoresForWorld { levels } =
    levels
        |> mapValues .tileSettings
        |> Dict.values
        |> List.concat
        |> totalScoresDict


totalScoresDict : List TileSetting -> Dict String Int
totalScoresDict =
    List.foldr accumSettings Dict.empty


accumSettings : TileSetting -> Dict String Int -> Dict String Int
accumSettings val acc =
    case val.targetScore of
        Just (TargetScore n) ->
            insertWith (+) (toString val.tileType) n acc

        Nothing ->
            acc
