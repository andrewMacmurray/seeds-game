module Data.Level.Board.Probabilities exposing (..)

import Scenes.Level.Types exposing (..)


tileProbability : List TileSetting -> Int -> TileType
tileProbability tileSettings n =
    tileSettings
        |> List.sortBy .probability
        |> List.foldl (handleProb n) ( Nothing, 0 )
        |> Tuple.first
        |> Maybe.withDefault SeedPod


handleProb : Int -> TileSetting -> ( Maybe TileType, Int ) -> ( Maybe TileType, Int )
handleProb n { tileType, probability } ( val, accProb ) =
    case val of
        Nothing ->
            if n <= probability + accProb then
                ( Just tileType, probability )
            else
                ( Nothing, probability + accProb )

        Just tileType ->
            ( Just tileType, probability )
