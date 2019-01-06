module Data.Level.Setting exposing
    ( Probability(..)
    , TargetScore(..)
    , TileSetting
    , burst
    , rain
    , seed
    , seedPod
    , sun
    )

import Data.Board.Types exposing (SeedType, TileType(..))


type alias TileSetting =
    { tileType : TileType
    , probability : Probability
    , targetScore : Maybe TargetScore
    }


type TargetScore
    = TargetScore Int


type Probability
    = Probability Int


rain : Probability -> TargetScore -> TileSetting
rain prob targetScore =
    TileSetting Rain prob <| Just targetScore


sun : Probability -> TargetScore -> TileSetting
sun prob targetScore =
    TileSetting Sun prob <| Just targetScore


seed : SeedType -> Probability -> TargetScore -> TileSetting
seed seedType prob targetScore =
    TileSetting (Seed seedType) prob <| Just targetScore


seedPod : Probability -> TileSetting
seedPod prob =
    TileSetting SeedPod prob Nothing


burst : Probability -> TileSetting
burst prob =
    TileSetting (Burst Nothing) prob Nothing
