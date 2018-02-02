module Data.Level.Summary exposing (..)

import Config.AllLevels exposing (allLevels)
import Dict exposing (Dict)
import Helpers.Dict exposing (insertWith, mapValues)
import Scenes.Hub.Types exposing (Progress, WorldData)
import Scenes.Level.Types exposing (SeedType, TargetScore(..), TileSetting, TileType)


percentComplete : TileType -> Progress -> Maybe Progress -> Float
percentComplete tileType ( w, l ) currentLevel =
    let
        target =
            totalTargetScoresForWorld w |> Maybe.andThen (Dict.get (toString tileType))

        current =
            currentTotalScoresForWorld ( w, l ) |> Maybe.andThen (Dict.get (toString tileType))

        percent a b =
            (toFloat b / toFloat a) * 100
    in
        if worldComplete ( w, l ) currentLevel then
            100
        else
            Maybe.map2 percent target current |> Maybe.withDefault 0


primarySeedType : Progress -> Maybe Progress -> Maybe SeedType
primarySeedType progress currentLevel =
    if worldComplete progress currentLevel then
        currentLevel |> Maybe.andThen worldSeedType
    else
        worldSeedType progress


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


getWorld : Progress -> Maybe WorldData
getWorld ( w, _ ) =
    Dict.get w allLevels


totalTargetScoresForWorld : Int -> Maybe (Dict String Int)
totalTargetScoresForWorld worldNumber =
    allLevels
        |> Dict.get worldNumber
        |> Maybe.map scoresForWorld


scoresAtLevel : Int -> WorldData -> Dict String Int
scoresAtLevel level { levels } =
    levels
        |> mapValues .tileSettings
        |> Dict.filter (\k _ -> k < level)
        |> Dict.values
        |> List.concat
        |> totalScoresDict


scoresForWorld : WorldData -> Dict String Int
scoresForWorld { levels } =
    levels
        |> mapValues .tileSettings
        |> Dict.values
        |> List.concat
        |> totalScoresDict


totalScoresDict : List TileSetting -> Dict String Int
totalScoresDict allSettings =
    List.foldr accumSettings Dict.empty allSettings


accumSettings : TileSetting -> Dict String Int -> Dict String Int
accumSettings val acc =
    case val.targetScore of
        Just (TargetScore n) ->
            insertWith (+) (toString val.tileType) n acc

        Nothing ->
            acc
