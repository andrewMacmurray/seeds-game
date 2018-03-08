module Data.Hub.LoadLevel exposing (..)

import Data.Level.Board.Block exposing (addWalls)
import Data.Level.Score exposing (initialScores)
import Scenes.Hub.Types as Main
import Scenes.Hub.Types exposing (..)
import Scenes.Level.Types as Level exposing (LevelStatus(InProgress))
import Scenes.Level.State exposing (levelInit)


handleLoadLevel : ( WorldData, LevelData ) -> Main.Model -> ( Main.Model, Cmd Main.Msg )
handleLoadLevel (( _, levelData ) as config) model =
    let
        newModel =
            { model | levelModel = initWithLevelData config model.levelModel }
    in
        newModel ! [ levelInit levelData newModel ]


initWithLevelData : ( WorldData, LevelData ) -> Level.Model -> Level.Model
initWithLevelData ( worldData, { tileSettings, walls, boardDimensions, moves } ) model =
    { model
        | scores = initialScores tileSettings
        , board = addWalls walls model.board
        , boardDimensions = boardDimensions
        , tileSettings = tileSettings
        , levelStatus = InProgress
        , remainingMoves = moves
    }
