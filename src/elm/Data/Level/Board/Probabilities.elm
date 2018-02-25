module Data.Level.Board.Probabilities exposing (..)

import Scenes.Level.Types exposing (..)


tileProbability : List TileSetting -> Int -> TileType
tileProbability tileSettings n =
    tileSettings
        |> List.foldl (handleProb n) ( Nothing, 0 )
        |> Tuple.first
        |> Maybe.withDefault SeedPod


handleProb : Int -> TileSetting -> ( Maybe TileType, Int ) -> ( Maybe TileType, Int )
handleProb n { tileType, probability } ( val, accProb ) =
    let
        (Probability p) =
            probability
    in
        case val of
            Nothing ->
                if n <= p + accProb then
                    ( Just tileType, p )
                else
                    ( Nothing, p + accProb )

            Just tileType ->
                ( Just tileType, p )
