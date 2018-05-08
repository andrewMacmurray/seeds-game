module Data.Level.Summary
    exposing
        ( percentComplete
        , primarySeedType
        , secondaryResourceTypes
        )

import Config.Levels exposing (allLevels)
import Data.Board.Score exposing (collectable)
import Data.Board.Tile exposing (getSeedType)
import Data.Board.Types exposing (..)
import Data.Level.Types exposing (..)
import Dict exposing (Dict)
import Helpers.Dict exposing (insertWith, mapValues)


percentComplete : AllLevels tutorial -> TileType -> Progress -> Maybe Progress -> Float
percentComplete allLevels tileType ( w, l ) currentLevel =
    let
        target =
            totalTargetScoresForWorld w
                |> Maybe.andThen (Dict.get (toString tileType))

        current =
            currentTotalScoresForWorld allLevels ( w, l )
                |> Maybe.andThen (Dict.get (toString tileType))

        percent a b =
            (toFloat b / toFloat a) * 100
    in
    if worldComplete ( w, l ) currentLevel then
        100
    else
        Maybe.map2 percent target current
            |> Maybe.withDefault 0


primarySeedType : AllLevels tutorial -> Progress -> Maybe Progress -> Maybe SeedType
primarySeedType allLevels progress currentLevel =
    if worldComplete progress currentLevel then
        currentLevel |> Maybe.andThen (worldSeedType allLevels)
    else
        worldSeedType allLevels progress


secondaryResourceTypes : AllLevels tutorial -> Maybe Progress -> Maybe (List TileType)
secondaryResourceTypes allLevels currentLevel =
    currentLevel
        |> Maybe.andThen (getWorld allLevels)
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


worldSeedType : AllLevels tutorial -> Progress -> Maybe SeedType
worldSeedType allLevels =
    getWorld allLevels >> Maybe.map .seedType


currentTotalScoresForWorld : AllLevels tutorial -> Progress -> Maybe (Dict String Int)
currentTotalScoresForWorld allLevels (( worldNumber, levelNumber ) as progress) =
    getWorld allLevels progress |> Maybe.map (scoresAtLevel levelNumber)


getWorld : AllLevels tutorial -> Progress -> Maybe (WorldData tutorial)
getWorld allLevels ( w, _ ) =
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
