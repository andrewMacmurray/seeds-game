module Data.Level.Summary exposing
    ( percentComplete
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


secondaryResourceTypes : Levels.Key -> Maybe (List TileType)
secondaryResourceTypes level =
    Maybe.map2
        secondaryResourceTypes_
        (Worlds.seedType level)
        (Worlds.getLevels level)


percentComplete : TileType -> Levels.Key -> Float
percentComplete tileType progress =
    let
        target =
            targetWorldScores progress |> Maybe.andThen (getScoreFor tileType)

        current =
            scoresAtLevel progress |> getScoreFor tileType

        percent a b =
            (toFloat b / toFloat a) * 100
    in
    if worldComplete progress then
        100

    else
        Maybe.map2 percent target current |> Maybe.withDefault 0


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
