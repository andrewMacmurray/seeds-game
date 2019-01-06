module Data.Board.Score exposing
    ( addScoreFromMoves
    , collectable
    , getScoreFor
    , initialScores
    , levelComplete
    , scoreTileTypes
    , scoreToString
    )

import Data.Board.Block as Block
import Data.Board.Move exposing (currentMoveTileType, currentMoves)
import Data.Board.Tile as Tile
import Data.Board.Types exposing (..)
import Data.Level.Setting exposing (..)
import Dict exposing (Dict)


addScoreFromMoves : Board -> Scores -> Scores
addScoreFromMoves board scores =
    let
        tileType =
            currentMoveTileType board |> Maybe.withDefault SeedPod

        scoreToAdd =
            currentMoves board
                |> List.filter (Tuple.second >> Block.isBurst >> not)
                |> List.length
    in
    addToScore scoreToAdd tileType scores


levelComplete : Scores -> Bool
levelComplete scores =
    scores |> Dict.foldl (\_ v b -> b && v.current == v.target) True


targetReached : TileType -> Scores -> Bool
targetReached tileType scores =
    scores
        |> Dict.get (Tile.hash tileType)
        |> Maybe.map (\s -> s.current == s.target)
        |> Maybe.withDefault False


scoreToString : TileType -> Scores -> String
scoreToString tileType scores =
    getScoreFor tileType scores
        |> Maybe.map String.fromInt
        |> Maybe.withDefault ""


getScoreFor : TileType -> Scores -> Maybe Int
getScoreFor tileType scores =
    scores
        |> Dict.get (Tile.hash tileType)
        |> Maybe.map (\{ target, current } -> target - current)


addToScore : Int -> TileType -> Scores -> Scores
addToScore score tileType scores =
    scores |> Dict.update (Tile.hash tileType) (Maybe.map (updateScore score))


updateScore : Int -> Score -> Score
updateScore n score =
    if score.current + n >= score.target then
        { score | current = score.target }

    else
        { score | current = score.current + n }


scoreTileTypes : List TileSetting -> List TileType
scoreTileTypes tileSettings =
    tileSettings
        |> List.filter collectable
        |> List.map .tileType


initialScores : List TileSetting -> Scores
initialScores tileSettings =
    tileSettings
        |> List.filter collectable
        |> List.map initScore
        |> Dict.fromList


collectable : TileSetting -> Bool
collectable { targetScore } =
    targetScore /= Nothing


initScore : TileSetting -> ( String, Score )
initScore { tileType, targetScore } =
    let
        (TargetScore t) =
            Maybe.withDefault (TargetScore 0) targetScore
    in
    ( Tile.hash tileType, Score t 0 )
