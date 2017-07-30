module Data.Hub.Progress exposing (..)

import Dict
import Model exposing (HubData, Progress, WorldData, Model)


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
