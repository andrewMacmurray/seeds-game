module Game.Level.Tile exposing
    ( Probability
    , Setting
    , TargetScore
    , burst
    , probability
    , rain
    , seed
    , seedPod
    , seedSettings
    , sortByProbability
    , sun
    , targetScore
    )

import Game.Board.Tile as Tile exposing (Tile(..))
import Seed exposing (Seed)



-- Tile Settings


type alias Setting =
    { tileType : Tile
    , probability : Probability
    , targetScore : Maybe TargetScore
    }


type TargetScore
    = TargetScore Int


type Probability
    = Probability Int


type alias SeedOptions =
    { seed : Seed
    , probability : Int
    , targetScore : Int
    }


type alias WeatherOptions =
    { probability : Int
    , targetScore : Int
    }


type alias MechanicOptions =
    { probability : Int
    }



-- Construct


rain : WeatherOptions -> Setting
rain options =
    { tileType = Rain
    , probability = Probability options.probability
    , targetScore = Just (TargetScore options.targetScore)
    }


sun : WeatherOptions -> Setting
sun options =
    { tileType = Sun
    , probability = Probability options.probability
    , targetScore = Just (TargetScore options.targetScore)
    }


seed : SeedOptions -> Setting
seed options =
    { tileType = Seed options.seed
    , probability = Probability options.probability
    , targetScore = Just (TargetScore options.targetScore)
    }


seedPod : MechanicOptions -> Setting
seedPod options =
    { tileType = SeedPod
    , probability = Probability options.probability
    , targetScore = Nothing
    }


burst : MechanicOptions -> Setting
burst options =
    { tileType = Burst Nothing
    , probability = Probability options.probability
    , targetScore = Nothing
    }



-- Query


seedSettings : List Setting -> List Setting
seedSettings =
    List.filter (.tileType >> Tile.isSeed)


sortByProbability : List Setting -> List Setting
sortByProbability =
    List.sortBy (.probability >> probability)


targetScore : TargetScore -> Int
targetScore (TargetScore t) =
    t


probability : Probability -> Int
probability (Probability n) =
    n
