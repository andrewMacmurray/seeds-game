module Data.Board.Scores exposing
    ( Score
    , Scores
    , addScoreFromMoves
    , allComplete
    , collectible
    , getScoreFor
    , init
    , tileTypes
    , toString
    )

import Data.Board as Board
import Data.Board.Block as Block
import Data.Board.Move as Move
import Data.Board.Tile as Tile exposing (Type(..))
import Data.Board.Types exposing (..)
import Data.Level.Setting.Tile as Tile
import Dict exposing (Dict)


type Scores
    = Scores (Dict String Score)


type alias Score =
    { target : Int
    , current : Int
    }


init : List Tile.Setting -> Scores
init =
    List.filter collectible
        >> List.map initScore
        >> Dict.fromList
        >> Scores


addScoreFromMoves : Board -> Scores -> Scores
addScoreFromMoves board scores =
    let
        tileType =
            Board.currentMoveType board |> Maybe.withDefault SeedPod

        isCollectible =
            Move.block >> Block.isCollectible

        scoreToAdd =
            Board.currentMoves board
                |> List.filter isCollectible
                |> List.length
    in
    addToScore scoreToAdd tileType scores


allComplete : Scores -> Bool
allComplete (Scores scores) =
    Dict.foldl (\_ v b -> b && v.current == v.target) True scores


toString : Tile.Type -> Scores -> String
toString tileType scores =
    getScoreFor tileType scores
        |> Maybe.map String.fromInt
        |> Maybe.withDefault ""


getScoreFor : Tile.Type -> Scores -> Maybe Int
getScoreFor tileType =
    getScore tileType >> Maybe.map (\{ target, current } -> target - current)


addToScore : Int -> Tile.Type -> Scores -> Scores
addToScore score tileType (Scores scores) =
    scores
        |> Dict.update (Tile.hash tileType) (Maybe.map (updateScore score))
        |> Scores


getScore : Tile.Type -> Scores -> Maybe Score
getScore tileType (Scores scores) =
    Dict.get (Tile.hash tileType) scores


updateScore : Int -> Score -> Score
updateScore n score =
    if score.current + n >= score.target then
        { score | current = score.target }

    else
        { score | current = score.current + n }


tileTypes : List Tile.Setting -> List Tile.Type
tileTypes =
    List.filter collectible >> List.map .tileType


collectible : Tile.Setting -> Bool
collectible { targetScore } =
    targetScore /= Nothing


initScore : Tile.Setting -> ( String, Score )
initScore { tileType, targetScore } =
    let
        (Tile.TargetScore t) =
            Maybe.withDefault (Tile.TargetScore 0) targetScore
    in
    ( Tile.hash tileType, Score t 0 )
