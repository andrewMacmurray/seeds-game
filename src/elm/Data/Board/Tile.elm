module Data.Board.Tile exposing (..)


type TileType
    = Rain
    | Sun
    | SeedPod
    | Seed SeedType


type SeedType
    = Sunflower
    | Foxglove
    | Lupin
    | Marigold
    | Rose
    | GreyedOut


isSeed : TileType -> Bool
isSeed tileType =
    case tileType of
        Seed _ ->
            True

        _ ->
            False


getSeedType : TileType -> Maybe SeedType
getSeedType tileType =
    case tileType of
        Seed seedType ->
            Just seedType

        _ ->
            Nothing
