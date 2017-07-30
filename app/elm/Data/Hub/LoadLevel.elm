module Data.Hub.LoadLevel exposing (..)

import Data.Board.Block exposing (addWalls)
import Data.Board.Score exposing (initialScores, initialScoresFromProbabilites)
import Model as Main exposing (LevelData)
import Scenes.Level.Model as Level
import Scenes.Level.Update exposing (initCmd)


handleLoadLevel : LevelData -> Main.Model -> ( Main.Model, Cmd Main.Msg )
handleLoadLevel levelData model =
    let
        newModel =
            { model | levelModel = addLevelData levelData model.levelModel }
    in
        newModel ! [ initCmd levelData newModel ]


addLevelData : LevelData -> Level.Model -> Level.Model
addLevelData { tileProbabilities, walls } model =
    { model
        | scores = initialScoresFromProbabilites tileProbabilities
        , board = addWalls walls model.board
        , tileProbabilities = tileProbabilities
    }
