module Data.Level.Setting.Tile exposing
    ( Probability(..)
    , Setting
    , TargetScore(..)
    , burst
    , rain
    , seed
    , seedPod
    , sun
    )

import Data.Board.Tile as Tile exposing (SeedType, Type(..))


type alias Setting =
    { tileType : Tile.Type
    , probability : Probability
    , targetScore : Maybe TargetScore
    }


type TargetScore
    = TargetScore Int


type Probability
    = Probability Int



-- Settings


rain : Probability -> TargetScore -> Setting
rain prob targetScore =
    Setting Rain prob <| Just targetScore


sun : Probability -> TargetScore -> Setting
sun prob targetScore =
    Setting Sun prob <| Just targetScore


seed : SeedType -> Probability -> TargetScore -> Setting
seed seedType prob targetScore =
    Setting (Seed seedType) prob <| Just targetScore


seedPod : Probability -> Setting
seedPod prob =
    Setting SeedPod prob Nothing


burst : Probability -> Setting
burst prob =
    Setting (Burst Nothing) prob Nothing
