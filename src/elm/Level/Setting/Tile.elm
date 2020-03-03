module Level.Setting.Tile exposing
    ( Probability(..)
    , Setting
    , TargetScore(..)
    , burst
    , rain
    , seed
    , seedPod
    , seedSettings
    , sortByProbability
    , sun
    )

import Board.Tile as Tile exposing (Tile(..))
import Seed exposing (Seed)


type alias Setting =
    { tileType : Tile
    , probability : Probability
    , targetScore : Maybe TargetScore
    }


type TargetScore
    = TargetScore Int


type Probability
    = Probability Int



-- Construct


rain : Probability -> TargetScore -> Setting
rain prob targetScore =
    Setting Rain prob <| Just targetScore


sun : Probability -> TargetScore -> Setting
sun prob targetScore =
    Setting Sun prob <| Just targetScore


seed : Seed -> Probability -> TargetScore -> Setting
seed seed_ prob targetScore =
    Setting (Seed seed_) prob <| Just targetScore


seedPod : Probability -> Setting
seedPod prob =
    Setting SeedPod prob Nothing


burst : Probability -> Setting
burst prob =
    Setting (Burst Nothing) prob Nothing



-- Query


seedSettings : List Setting -> List Setting
seedSettings =
    List.filter (.tileType >> Tile.isSeed)


sortByProbability : List Setting -> List Setting
sortByProbability =
    List.sortBy (.probability >> unwrapProbability_)


unwrapProbability_ : Probability -> Int
unwrapProbability_ (Probability n) =
    n
