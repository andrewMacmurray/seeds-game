module Data.Board.Scores exposing
    ( Score
    , Scores
    , addScoreFromMoves
    , allComplete
    , collectable
    , getScoreFor
    , init
    , tileTypes
    , toString
    )

import Data.Board as Board
import Data.Board.Block as Block
import Data.Board.Move as Move
import Data.Board.Tile as Tile
import Data.Board.Types exposing (..)
import Data.Level.Setting exposing (..)
import Dict exposing (Dict)


type Scores
    = Scores (Dict String Score)


type alias Score =
    { target : Int
    , current : Int
    }


init : List TileSetting -> Scores
init =
    List.filter collectable
        >> List.map initScore
        >> Dict.fromList
        >> Scores


addScoreFromMoves : Board -> Scores -> Scores
addScoreFromMoves board scores =
    let
        tileType =
            Board.currentMoveType board |> Maybe.withDefault SeedPod

        notBurst =
            Move.block >> Block.isBurst >> not

        scoreToAdd =
            Board.currentMoves board
                |> List.filter notBurst
                |> List.length
    in
    addToScore scoreToAdd tileType scores


allComplete : Scores -> Bool
allComplete (Scores scores) =
    Dict.foldl (\_ v b -> b && v.current == v.target) True scores


targetReached : TileType -> Scores -> Bool
targetReached tileType =
    getScore tileType
        >> Maybe.map (\s -> s.current == s.target)
        >> Maybe.withDefault False


toString : TileType -> Scores -> String
toString tileType scores =
    getScoreFor tileType scores
        |> Maybe.map String.fromInt
        |> Maybe.withDefault ""


getScoreFor : TileType -> Scores -> Maybe Int
getScoreFor tileType =
    getScore tileType >> Maybe.map (\{ target, current } -> target - current)


addToScore : Int -> TileType -> Scores -> Scores
addToScore score tileType (Scores scores) =
    scores
        |> Dict.update (Tile.hash tileType) (Maybe.map (updateScore score))
        |> Scores


getScore : TileType -> Scores -> Maybe Score
getScore tileType (Scores scores) =
    Dict.get (Tile.hash tileType) scores


updateScore : Int -> Score -> Score
updateScore n score =
    if score.current + n >= score.target then
        { score | current = score.target }

    else
        { score | current = score.current + n }


tileTypes : List TileSetting -> List TileType
tileTypes =
    List.filter collectable >> List.map .tileType


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
