module Data.Level.Board.Probabilities exposing (..)

import Scenes.Level.Model exposing (..)


tileProbability : List TileProbability -> Int -> TileType
tileProbability probabilities n =
    probabilities
        |> List.sortBy Tuple.second
        |> List.foldl (handleProb n) ( Nothing, 0 )
        |> Tuple.first
        |> Maybe.withDefault SeedPod


handleProb : Int -> TileProbability -> ( Maybe TileType, Int ) -> ( Maybe TileType, Int )
handleProb n ( tileType, prob ) ( val, accProb ) =
    case val of
        Nothing ->
            if n < prob + accProb then
                ( Just tileType, prob )
            else
                ( Nothing, prob + accProb )

        Just tileType ->
            ( Just tileType, prob )
