module Data.Hub.Progress exposing (..)

import Data.Hub.Config exposing (level5, world1)
import Dict
import Data.Hub.Types exposing (..)
import Data.Level.Types exposing (SeedType(..))
import Scenes.Hub.Model exposing (HubModel)


getSelectedProgress : HubModel -> Maybe LevelProgress
getSelectedProgress model =
    case model.infoWindow of
        Hidden ->
            Nothing

        Visible progress ->
            Just progress

        Leaving progress ->
            Just progress


getLevelConfig : LevelProgress -> HubModel -> ( WorldData, LevelData )
getLevelConfig ( w, l ) model =
    let
        worldData =
            model.hubData |> Dict.get w

        levelData =
            worldData |> Maybe.andThen (\w -> Dict.get l w.levels)
    in
        ( worldData |> Maybe.withDefault world1
        , levelData |> Maybe.withDefault level5
        )


currentLevelSeedType : HubModel -> SeedType
currentLevelSeedType ({ hubData, currentLevel } as model) =
    currentLevel
        |> Maybe.map Tuple.first
        |> Maybe.andThen (\world -> Dict.get world hubData)
        |> Maybe.map .seedType
        |> Maybe.withDefault (currentProgressSeedType model)


currentProgressSeedType : HubModel -> SeedType
currentProgressSeedType { hubData, progress } =
    hubData
        |> Dict.get (Tuple.first progress)
        |> Maybe.map .seedType
        |> Maybe.withDefault GreyedOut


completedLevel : ( WorldNumber, LevelNumber ) -> HubModel -> Bool
completedLevel ( world, level ) { progress, hubData } =
    getLevelNumber progress hubData > getLevelNumber ( world, level ) hubData


reachedLevel : ( WorldNumber, LevelNumber ) -> HubModel -> Bool
reachedLevel ( world, level ) { progress, hubData } =
    getLevelNumber progress hubData >= getLevelNumber ( world, level ) hubData


getLevelNumber : LevelProgress -> HubData -> Int
getLevelNumber ( world, level ) hubData =
    List.range 1 (world - 1)
        |> List.foldl (\w acc -> acc + worldSize w hubData) 0
        |> ((+) level)


worldSize : Int -> HubData -> Int
worldSize world hubData =
    hubData
        |> Dict.get world
        |> Maybe.map (.levels >> Dict.size)
        |> Maybe.withDefault 0


handleIncrementProgress : HubModel -> HubModel
handleIncrementProgress model =
    { model | progress = incrementProgress model.progress model.hubData }


incrementProgress : LevelProgress -> HubData -> LevelProgress
incrementProgress (( world, level ) as currentProgress) hubData =
    hubData
        |> Dict.get world
        |> Maybe.map (handleIncrement currentProgress)
        |> Maybe.withDefault ( 0, 0 )


handleIncrement : LevelProgress -> WorldData -> LevelProgress
handleIncrement (( _, level ) as currentProgress) worldData =
    if lastLevel worldData == level then
        incrementWorld currentProgress
    else
        incrementLevel currentProgress


lastLevel : WorldData -> Int
lastLevel worldData =
    Dict.size worldData.levels


incrementWorld : LevelProgress -> LevelProgress
incrementWorld ( world, _ ) =
    ( world + 1, 1 )


incrementLevel : LevelProgress -> LevelProgress
incrementLevel ( world, level ) =
    ( world, level + 1 )
