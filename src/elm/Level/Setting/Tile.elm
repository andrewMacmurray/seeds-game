module Level.Setting.Tile exposing
    ( Probability(..)
    , Setting
    , TargetScore(..)
    , burst
    , pod
    , rain
    , seed
    , sun
    )

import Board.Tile exposing (Tile(..))
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



-- Settings


rain : Probability -> TargetScore -> Setting
rain prob targetScore =
    Setting Rain prob <| Just targetScore


sun : Probability -> TargetScore -> Setting
sun prob targetScore =
    Setting Sun prob <| Just targetScore


seed : Seed -> Probability -> TargetScore -> Setting
seed seed_ prob targetScore =
    Setting (Seed seed_) prob <| Just targetScore


pod : Probability -> Setting
pod prob =
    Setting Pod prob Nothing


burst : Probability -> Setting
burst prob =
    Setting (Burst Nothing) prob Nothing
