module Data.Hub.Progress exposing (..)

import Dict
import Model exposing (..)
import Scenes.Level.Model exposing (SeedType(..))


currentLevelSeedType : Model -> SeedType
currentLevelSeedType ({ hubData, currentLevel } as model) =
    currentLevel
        |> Maybe.map Tuple.first
        |> Maybe.andThen (\world -> Dict.get world hubData)
        |> Maybe.map .seedType
        |> Maybe.withDefault (currentProgressSeedType model)


currentProgressSeedType : Model -> SeedType
currentProgressSeedType { hubData, progress } =
    hubData
        |> Dict.get (Tuple.first progress)
        |> Maybe.map .seedType
        |> Maybe.withDefault GreyedOut


reachedLevel : ( WorldNumber, LevelNumber ) -> Model -> Bool
reachedLevel ( world, level ) { progress, hubData } =
    getLevelNumber progress hubData >= getLevelNumber ( world, level ) hubData


getLevelNumber : Progress -> HubData -> Int
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


handleIncrementProgress : Model -> Model
handleIncrementProgress model =
    { model | progress = incrementProgress model.progress model.hubData }


incrementProgress : Progress -> HubData -> Progress
incrementProgress (( world, level ) as currentProgress) hubData =
    hubData
        |> Dict.get world
        |> Maybe.map (handleIncrement currentProgress)
        |> Maybe.withDefault ( 0, 0 )


handleIncrement : Progress -> WorldData -> Progress
handleIncrement (( _, level ) as currentProgress) worldData =
    if lastLevel worldData == level then
        incrementWorld currentProgress
    else
        incrementLevel currentProgress


lastLevel : WorldData -> Int
lastLevel worldData =
    Dict.size worldData.levels


incrementWorld : Progress -> Progress
incrementWorld ( world, _ ) =
    ( world + 1, 1 )


incrementLevel : Progress -> Progress
incrementLevel ( world, level ) =
    ( world, level + 1 )
