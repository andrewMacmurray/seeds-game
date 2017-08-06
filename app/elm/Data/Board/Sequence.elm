module Data.Board.Sequence exposing (..)

import Helpers.Delay exposing (sequenceMs)
import Scenes.Level.Model exposing (..)


growSeedPodsSequence : Cmd Msg
growSeedPodsSequence =
    sequenceMs
        [ ( 0, SetGrowingSeedPods )
        , ( 0, ResetMove )
        , ( 800, GrowPodsToSeeds )
        , ( 600, ResetGrowingSeeds )
        ]


removeTilesSequence : Model -> MoveShape -> Cmd Msg
removeTilesSequence model moveShape =
    sequenceMs
        [ ( 0, SetLeavingTiles )
        , ( 0, ResetMove )
        , ( fallDelay model moveShape, SetFallingTiles )
        , ( 1000, ShiftBoard )
        , ( 0, MakeNewTiles )
        , ( 500, ResetEntering )
        ]


fallDelay : Model -> MoveShape -> Float
fallDelay model moveShape =
    if moveShape == Square then
        500
    else
        350
