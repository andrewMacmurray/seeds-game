module Game.Board.Scores exposing
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

import Dict exposing (Dict)
import Game.Board as Board exposing (Board)
import Game.Board.Block as Block
import Game.Board.Move as Move
import Game.Board.Tile as Tile exposing (Tile(..))
import Game.Level.Tile as Tile



-- Scores


type Scores
    = Scores (Dict String Score)


type alias Score =
    { target : Int
    , current : Int
    }



-- Construct


init : List Tile.Setting -> Scores
init =
    List.filter collectible
        >> List.map initScore
        >> Dict.fromList
        >> Scores


initScore : Tile.Setting -> ( String, Score )
initScore setting =
    ( Tile.toString setting.tileType
    , Score (targetValue setting.targetScore) 0
    )


targetValue : Maybe Tile.TargetScore -> Int
targetValue =
    Maybe.map Tile.targetScore >> Maybe.withDefault 0



-- Update


addScoreFromMoves : Board -> Scores -> Scores
addScoreFromMoves board scores =
    let
        tileType =
            Board.activeMoveType board |> Maybe.withDefault SeedPod

        isCollectible =
            Move.block >> Block.isCollectible

        scoreToAdd =
            Board.activeMoves board
                |> List.filter isCollectible
                |> List.length
    in
    addToScore scoreToAdd tileType scores


addToScore : Int -> Tile -> Scores -> Scores
addToScore score tileType (Scores scores) =
    scores
        |> Dict.update (Tile.toString tileType) (Maybe.map (updateScore score))
        |> Scores


updateScore : Int -> Score -> Score
updateScore n score =
    if score.current + n >= score.target then
        { score | current = score.target }

    else
        { score | current = score.current + n }



-- Query


allComplete : Scores -> Bool
allComplete (Scores scores) =
    Dict.foldl (\_ v b -> b && v.current == v.target) True scores


toString : Tile -> Scores -> String
toString tileType scores =
    getScoreFor tileType scores
        |> Maybe.map String.fromInt
        |> Maybe.withDefault ""


getScoreFor : Tile -> Scores -> Maybe Int
getScoreFor tileType =
    getScore tileType >> Maybe.map (\{ target, current } -> target - current)


getScore : Tile -> Scores -> Maybe Score
getScore tileType (Scores scores) =
    Dict.get (Tile.toString tileType) scores


tileTypes : List Tile.Setting -> List Tile
tileTypes =
    List.filter collectible >> List.map .tileType


collectible : Tile.Setting -> Bool
collectible { targetScore } =
    targetScore /= Nothing
