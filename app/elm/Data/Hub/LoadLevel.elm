module Data.Hub.LoadLevel exposing (..)

import Data.Level.Board.Block exposing (addWalls)
import Data.Level.Score exposing (initialScores)
import Scenes.Hub.Types as Main
import Scenes.Hub.Types exposing (..)
import Scenes.Level.Types as Level
import Scenes.Level.State exposing (initCmd)


handleLoadLevel : ( WorldData, LevelData ) -> Main.Model -> ( Main.Model, Cmd Main.Msg )
handleLoadLevel (( _, levelData ) as config) model =
    let
        newModel =
            { model | levelModel = addLevelData config model.levelModel }
    in
        newModel ! [ initCmd levelData newModel ]


addLevelData : ( WorldData, LevelData ) -> Level.Model -> Level.Model
addLevelData ( worldData, { tileSettings, walls } ) model =
    { model
        | scores = initialScores tileSettings
        , board = addWalls walls model.board
        , tileSettings = tileSettings
        , seedType = worldData.seedType
    }
