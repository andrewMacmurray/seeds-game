module Data.Hub.LoadLevel exposing (..)

import Data.Level.Board.Block exposing (addWalls)
import Data.Level.Score exposing (initialScores, initialScoresFromProbabilites)
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
addLevelData ( worldData, { tileProbabilities, walls } ) model =
    { model
        | scores = initialScoresFromProbabilites tileProbabilities
        , board = addWalls walls model.board
        , tileProbabilities = tileProbabilities
        , seedType = worldData.seedType
    }
