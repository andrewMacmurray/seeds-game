module Data.Level.Progress exposing (..)

import Config.Levels exposing (allLevels, defaultLevel, defaultWorld)
import Data.Board.Types exposing (..)
import Data.Level.Types exposing (..)
import Dict
import Scenes.Tutorial.Types as Tutorial


getLevelData : Progress -> LevelData Tutorial.Config
getLevelData progress =
    getLevelConfig progress |> Tuple.second


getLevelConfig : Progress -> ( WorldData Tutorial.Config, LevelData Tutorial.Config )
getLevelConfig ( w, l ) =
    let
        worldData =
            allLevels |> Dict.get w

        levelData =
            worldData |> Maybe.andThen (\w -> Dict.get l w.levels)
    in
        ( worldData |> Maybe.withDefault defaultWorld
        , levelData |> Maybe.withDefault defaultLevel
        )


currentLevelSeedType : Maybe Progress -> Progress -> SeedType
currentLevelSeedType currentLevel progress =
    currentLevel
        |> Maybe.map Tuple.first
        |> Maybe.andThen (\world -> Dict.get world allLevels)
        |> Maybe.map .seedType
        |> Maybe.withDefault (currentProgressSeedType progress)


currentProgressSeedType : Progress -> SeedType
currentProgressSeedType progress =
    allLevels
        |> Dict.get (Tuple.first progress)
        |> Maybe.map .seedType
        |> Maybe.withDefault Sunflower


completedLevel : ( WorldNumber, LevelNumber ) -> Progress -> Bool
completedLevel ( world, level ) progress =
    getLevelNumber progress allLevels > getLevelNumber ( world, level ) allLevels


reachedLevel : ( WorldNumber, LevelNumber ) -> Progress -> Bool
reachedLevel ( world, level ) progress =
    getLevelNumber progress allLevels >= getLevelNumber ( world, level ) allLevels


getLevelNumber : Progress -> AllLevels Tutorial.Config -> Int
getLevelNumber ( world, level ) allLevels =
    List.range 1 (world - 1)
        |> List.foldl (\w acc -> acc + worldSize w allLevels) 0
        |> ((+) level)


worldSize : Int -> AllLevels Tutorial.Config -> Int
worldSize world allLevels =
    allLevels
        |> Dict.get world
        |> Maybe.map (.levels >> Dict.size)
        |> Maybe.withDefault 0


incrementProgress : Maybe Progress -> Progress -> Progress
incrementProgress currentLevel (( world, level ) as currentProgress) =
    allLevels
        |> Dict.get world
        |> Maybe.map (compareLevels currentLevel currentProgress)
        |> Maybe.withDefault currentProgress


compareLevels : Maybe Progress -> Progress -> WorldData Tutorial.Config -> Progress
compareLevels currentLevel progress worldData =
    if shouldIncrement currentLevel progress then
        handleIncrement progress worldData
    else
        progress


shouldIncrement : Maybe Progress -> Progress -> Bool
shouldIncrement currentLevel progress =
    let
        curr =
            getLevelNumber (Maybe.withDefault ( 1, 1 ) currentLevel) allLevels

        prog =
            getLevelNumber progress allLevels
    in
        curr >= prog


handleIncrement : Progress -> WorldData Tutorial.Config -> Progress
handleIncrement (( _, level ) as currentProgress) worldData =
    if lastLevel worldData == level then
        incrementWorld currentProgress
    else
        incrementLevel currentProgress


lastLevel : WorldData Tutorial.Config -> Int
lastLevel worldData =
    Dict.size worldData.levels


incrementWorld : Progress -> Progress
incrementWorld ( world, _ ) =
    ( world + 1, 1 )


incrementLevel : Progress -> Progress
incrementLevel ( world, level ) =
    ( world, level + 1 )
