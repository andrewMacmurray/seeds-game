module Data.Hub.Text exposing (..)

import Data.Level.Board.Tile exposing (isSeedTile)
import Scenes.Level.Types exposing (TileType(..))


infoText : List TileType -> String
infoText types =
    if onlySeeds types then
        "collect the seeds"
    else if rainAndSeeds types then
        "collect rain and seeds"
    else if sunAndSeeds types then
        "collect sun and seeds"
    else if allThree types then
        "collect rain, sun and seeds"
    else
        ""


allThree : List TileType -> Bool
allThree types =
    allPass types
        [ containsSeed
        , contains Rain
        , contains Sun
        ]


sunAndSeeds : List TileType -> Bool
sunAndSeeds types =
    allPass types
        [ containsSeed
        , contains Sun
        , not << contains Rain
        ]


rainAndSeeds : List TileType -> Bool
rainAndSeeds types =
    allPass types
        [ containsSeed
        , contains Rain
        , not << contains Sun
        ]


onlySeeds : List TileType -> Bool
onlySeeds types =
    allPass types
        [ containsSeed
        , not << contains Sun
        , not << contains Rain
        ]


containsSeed : List TileType -> Bool
containsSeed =
    List.any isSeedTile


allPass : List TileType -> List (List TileType -> Bool) -> Bool
allPass types xs =
    xs
        |> List.map (\f -> f types)
        |> List.foldr (&&) True


contains : TileType -> List TileType -> Bool
contains tileType =
    List.any ((==) tileType)
