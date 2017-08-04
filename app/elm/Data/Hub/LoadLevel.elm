module Data.Hub.LoadLevel exposing (..)

import Data.Board.Block exposing (addWalls)
import Data.Board.Score exposing (initialScores, initialScoresFromProbabilites)
import Model as Main exposing (LevelData, WorldData)
import Scenes.Level.Model as Level
import Scenes.Level.Update exposing (initCmd)


handleLoadLevel : ( WorldData, LevelData ) -> Main.Model -> ( Main.Model, Cmd Main.Msg )
handleLoadLevel config model =
    let
        newModel =
            { model | levelModel = addLevelData config model.levelModel }
    in
        newModel ! [ initCmd config newModel ]


addLevelData : ( WorldData, LevelData ) -> Level.Model -> Level.Model
addLevelData ( worldData, { tileProbabilities, walls } ) model =
    { model
        | scores = initialScoresFromProbabilites tileProbabilities
        , board = addWalls walls model.board
        , tileProbabilities = tileProbabilities
        , seedType = worldData.seedType
    }
