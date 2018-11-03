module Data.Level.Summary exposing
    ( percentComplete
    , primaryResourceType
    , scoreDifference
    , secondaryResourceTypes
    )

import Data.Board.Score exposing (collectable)
import Data.Board.Tile as Tile exposing (getSeedType)
import Data.Board.Types exposing (..)
import Data.Level.Types exposing (TargetScore(..), TileSetting)
import Data.Levels as Levels
import Dict exposing (Dict)
import Helpers.Dict exposing (insertWith, mapValues)
import Helpers.List exposing (unique)
import Worlds


primaryResourceType : Levels.Key -> Maybe Levels.Key -> Maybe SeedType
primaryResourceType progress currentLevel =
    levelOffset progress currentLevel |> Worlds.seedType


secondaryResourceTypes : Levels.Key -> Maybe Levels.Key -> Maybe (List TileType)
secondaryResourceTypes progress currentLevel =
    Maybe.map2
        secondaryResourceTypes_
        (Worlds.seedType <| levelOffset progress currentLevel)
        (Worlds.getLevels <| levelOffset progress currentLevel)


scoreDifference : TileType -> Levels.Key -> Maybe Levels.Key -> Maybe Int
scoreDifference tileType progress currentLevel =
    let
        _ =
            Debug.log "curr" progress

        _ =
            Debug.log "prev" (Worlds.previous progress)

        totalScores =
            targetWorldScores progress
                |> Maybe.andThen (getScoreFor tileType)

        targetScore =
            scoresAtLevel progress
                |> Debug.log "target"
                |> getScoreFor tileType

        score =
            scoresAtLevel (Worlds.previous progress)
                |> Debug.log "current"
                |> getScoreFor tileType
    in
    if displayFinal progress currentLevel then
        Maybe.map2 (-) totalScores score

    else
        Maybe.map2 (-) targetScore score


percentComplete : TileType -> Levels.Key -> Maybe Levels.Key -> Float
percentComplete tileType progress currentLevel =
    let
        targetScores =
            targetWorldScores progress |> Maybe.andThen (getScoreFor tileType)

        currentScores =
            scoresAtLevel progress |> getScoreFor tileType

        percent a b =
            (toFloat b / toFloat a) * 100
    in
    if displayFinal progress currentLevel then
        100

    else if displayFirst progress currentLevel then
        0

    else
        Maybe.map2 percent targetScores currentScores |> Maybe.withDefault 0


displayFirst : Levels.Key -> Maybe Levels.Key -> Bool
displayFirst progress currentLevel =
    Levels.isFirstLevelOfWorld progress
        && (Maybe.map Levels.isFirstLevelOfWorld currentLevel |> Maybe.withDefault False)


displayFinal : Levels.Key -> Maybe Levels.Key -> Bool
displayFinal progress currentLevel =
    Levels.isFirstLevelOfWorld progress
        && (Maybe.map Worlds.isLastLevelOfWorld currentLevel |> Maybe.withDefault False)


levelOffset : Levels.Key -> Maybe Levels.Key -> Levels.Key
levelOffset progress currentLevel =
    if displayFinal progress currentLevel then
        Worlds.previous progress

    else
        progress


getScoreFor : TileType -> Dict String Int -> Maybe Int
getScoreFor =
    Tile.hash >> Dict.get


worldComplete : Levels.Key -> Bool
worldComplete =
    Levels.isFirstLevelOfWorld


secondaryResourceTypes_ : SeedType -> List Levels.Level -> List TileType
secondaryResourceTypes_ worldSeedType =
    List.map tileSettings
        >> List.concat
        >> List.filter collectable
        >> List.map .tileType
        >> List.filter (secondaryResource worldSeedType)
        >> unique


secondaryResource : SeedType -> TileType -> Bool
secondaryResource worldSeedType tileType =
    case getSeedType tileType of
        Just seedType ->
            not <| worldSeedType == seedType

        Nothing ->
            True


scoresAtLevel : Levels.Key -> Dict String Int
scoresAtLevel level =
    level
        |> Worlds.getKeysForWorld
        |> Maybe.withDefault []
        |> List.filter (Levels.completed level)
        |> List.map (Worlds.getLevel >> Maybe.map tileSettings >> Maybe.withDefault [])
        |> List.concat
        |> totalScoresDict


targetWorldScores : Levels.Key -> Maybe (Dict String Int)
targetWorldScores level =
    level
        |> Worlds.getLevels
        |> Maybe.map scoresForWorld


scoresForWorld : List Levels.Level -> Dict String Int
scoresForWorld levels =
    levels
        |> List.map tileSettings
        |> List.concat
        |> totalScoresDict


tileSettings : Levels.Level -> List TileSetting
tileSettings =
    Levels.config >> .tiles


totalScoresDict : List TileSetting -> Dict String Int
totalScoresDict =
    List.foldr accumSettings Dict.empty


accumSettings : TileSetting -> Dict String Int -> Dict String Int
accumSettings setting acc =
    case setting.targetScore of
        Just (TargetScore n) ->
            insertWith (+) (Tile.hash setting.tileType) n acc

        Nothing ->
            acc
