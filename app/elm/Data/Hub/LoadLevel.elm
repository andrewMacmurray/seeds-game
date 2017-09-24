module Data.Hub.LoadLevel exposing (..)

import Data.Level.Board.Block exposing (addWalls)
import Data.Level.Score exposing (initialScores, initialScoresFromProbabilites)
import Model as Main
import Data.Hub.Types exposing (..)
import Scenes.Level.Model exposing (LevelModel)
import Scenes.Level.Update exposing (initCmd)


handleLoadLevel : ( WorldData, LevelData ) -> Main.Model -> ( Main.Model, Cmd Main.Msg )
handleLoadLevel (( _, levelData ) as config) model =
    let
        newModel =
            { model | levelModel = addLevelData config model.levelModel }
    in
        newModel ! [ initCmd levelData newModel ]


addLevelData : ( WorldData, LevelData ) -> LevelModel -> LevelModel
addLevelData ( worldData, { tileProbabilities, walls } ) model =
    { model
        | scores = initialScoresFromProbabilites tileProbabilities
        , board = addWalls walls model.board
        , tileProbabilities = tileProbabilities
        , seedType = worldData.seedType
    }
