module Data.Progress exposing (..)

import Data.Board.Types exposing (..)
import Data.Level.Types exposing (..)
import Dict


levelData : AllLevels tutorial -> Progress -> Maybe (LevelData tutorial)
levelData allLevels progress =
    levelConfig allLevels progress |> Maybe.map Tuple.second


levelConfig : AllLevels tutorial -> Progress -> Maybe (CurrentLevelConfig tutorial)
levelConfig allLevels ( w, l ) =
    let
        worldData =
            allLevels |> Dict.get w

        levelData =
            worldData |> Maybe.andThen (\w -> Dict.get l w.levels)
    in
        Maybe.map2 (,) worldData levelData


currentLevelSeedType : AllLevels tutorial -> Maybe Progress -> Progress -> SeedType
currentLevelSeedType allLevels currentLevel progress =
    currentLevel
        |> Maybe.map Tuple.first
        |> Maybe.andThen (\world -> Dict.get world allLevels)
        |> Maybe.map .seedType
        |> Maybe.withDefault (currentProgressSeedType allLevels progress)


currentProgressSeedType : AllLevels tutorial -> Progress -> SeedType
currentProgressSeedType allLevels progress =
    allLevels
        |> Dict.get (Tuple.first progress)
        |> Maybe.map .seedType
        |> Maybe.withDefault Sunflower


completedLevel : AllLevels tutorial -> ( WorldNumber, LevelNumber ) -> Progress -> Bool
completedLevel allLevels ( world, level ) progress =
    getLevelNumber progress allLevels > getLevelNumber ( world, level ) allLevels


reachedLevel : AllLevels tutorial -> ( WorldNumber, LevelNumber ) -> Progress -> Bool
reachedLevel allLevels ( world, level ) progress =
    getLevelNumber progress allLevels >= getLevelNumber ( world, level ) allLevels


getLevelNumber : Progress -> AllLevels tutorial -> Int
getLevelNumber ( world, level ) allLevels =
    List.range 1 (world - 1)
        |> List.foldl (\w acc -> acc + worldSize w allLevels) 0
        |> ((+) level)


worldSize : Int -> AllLevels tutorial -> Int
worldSize world allLevels =
    allLevels
        |> Dict.get world
        |> Maybe.map (.levels >> Dict.size)
        |> Maybe.withDefault 0


incrementProgress : AllLevels tutorial -> Maybe Progress -> Progress -> Progress
incrementProgress allLevels currentLevel (( world, level ) as currentProgress) =
    allLevels
        |> Dict.get world
        |> Maybe.map (incrementProgress_ allLevels currentLevel currentProgress)
        |> Maybe.withDefault currentProgress


incrementProgress_ : AllLevels tutorial -> Maybe Progress -> Progress -> WorldData tutorial -> Progress
incrementProgress_ allLevels currentLevel progress worldData =
    if shouldIncrement allLevels currentLevel progress then
        handleIncrement progress worldData
    else
        progress


shouldIncrement : AllLevels tutorial -> Maybe Progress -> Progress -> Bool
shouldIncrement allLevels currentLevel progress =
    let
        curr =
            getLevelNumber (Maybe.withDefault ( 1, 1 ) currentLevel) allLevels

        prog =
            getLevelNumber progress allLevels
    in
        curr >= prog


handleIncrement : Progress -> WorldData tutorial -> Progress
handleIncrement (( _, level ) as currentProgress) worldData =
    if lastLevel worldData == level then
        incrementWorld currentProgress
    else
        incrementLevel currentProgress


lastLevel : WorldData tutorial -> Int
lastLevel worldData =
    Dict.size worldData.levels


incrementWorld : Progress -> Progress
incrementWorld ( world, _ ) =
    ( world + 1, 1 )


incrementLevel : Progress -> Progress
incrementLevel ( world, level ) =
    ( world, level + 1 )
