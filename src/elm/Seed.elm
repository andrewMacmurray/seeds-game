module Seed exposing
    ( Seed(..)
    , name
    )

-- Seed


type Seed
    = Sunflower
    | Chrysanthemum
    | Cornflower
    | Lupin
    | Marigold
    | Rose


name : Seed -> String
name seed =
    case seed of
        Sunflower ->
            "Sunflower"

        Chrysanthemum ->
            "Chrysanthemum"

        Cornflower ->
            "Cornflower"

        Lupin ->
            "Lupin"

        Marigold ->
            "Marigold"

        Rose ->
            "Rose"
