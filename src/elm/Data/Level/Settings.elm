module Data.Level.Settings exposing
    ( rain
    , seed
    , seedPod
    , sun
    )

import Data.Board.Types exposing (..)
import Data.Level.Types exposing (..)
import Helpers.Dict exposing (indexedDictFrom)


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
