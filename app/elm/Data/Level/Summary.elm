module Data.Level.Summary exposing (..)

import Config.AllLevels exposing (allLevels)
import Dict exposing (Dict)
import Helpers.Dict exposing (insertWith, mapValues)
import Scenes.Hub.Types exposing (Progress, WorldData)
import Scenes.Level.Types exposing (TargetScore(..), TileSetting, TileType)


percentComplete : TileType -> Progress -> Float
percentComplete tileType ( w, l ) =
    let
        target =
            totalTargetScoresForWorld w |> Maybe.andThen (Dict.get (toString tileType))

        current =
            currentTotalScoresForWorld ( w, l ) |> Maybe.andThen (Dict.get (toString tileType))
    in
        Maybe.map2 (\t c -> (toFloat c / toFloat t) * 100) target current
            |> Maybe.withDefault 0


currentTotalScoresForWorld : Progress -> Maybe (Dict String Int)
currentTotalScoresForWorld ( worldNumber, levelNumber ) =
    allLevels
        |> Dict.get worldNumber
        |> Maybe.map (scoresAtLevel levelNumber)


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
