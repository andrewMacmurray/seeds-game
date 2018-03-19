module Data2.Level.Score exposing (..)

import Data2.Board exposing (Board)
import Data2.Board.Move exposing (currentMoveTileType, currentMoves)
import Data2.Level.Settings exposing (TargetScore(..), TileSetting)
import Data2.Tile exposing (TileType(..))
import Dict exposing (Dict)


type alias Scores =
    Dict String Score


type alias Score =
    { target : Int
    , current : Int
    }


addScoreFromMoves : Board -> Scores -> Scores
addScoreFromMoves board scores =
    let
        tileType =
            currentMoveTileType board |> Maybe.withDefault SeedPod

        scoreToAdd =
            currentMoves board |> List.length
    in
        addToScore scoreToAdd tileType scores


levelComplete : Scores -> Bool
levelComplete scores =
    scores |> Dict.foldl (\_ v b -> b && v.current == v.target) True


targetReached : TileType -> Scores -> Bool
targetReached tileType scores =
    scores
        |> Dict.get (toString tileType)
        |> Maybe.map (\s -> s.current == s.target)
        |> Maybe.withDefault False


scoreToString : TileType -> Scores -> String
scoreToString tileType scores =
    getScoreFor tileType scores
        |> Maybe.map toString
        |> Maybe.withDefault ""


getScoreFor : TileType -> Scores -> Maybe Int
getScoreFor tileType scores =
    scores
        |> Dict.get (toString tileType)
        |> Maybe.map (\{ target, current } -> target - current)


addToScore : Int -> TileType -> Scores -> Scores
addToScore score tileType scores =
    scores |> Dict.update (toString tileType) (Maybe.map (updateScore score))


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
        ( toString tileType, Score t 0 )
