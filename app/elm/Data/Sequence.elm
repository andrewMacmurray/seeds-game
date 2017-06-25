module Data.Sequence exposing (..)

import Delay
import Model exposing (..)


growSeedPods : Cmd Msg
growSeedPods =
    Delay.start StopMoveSequence
        [ ( 0, SetGrowingSeedPods )
        , ( 0, ResetMove )
        , ( 800, GrowPodsToSeeds )
        , ( 600, ResetGrowingSeeds )
        ]


removeTiles : Model -> MoveType -> Cmd Msg
removeTiles model moveType =
    Delay.start StopMoveSequence
        [ ( 0, SetLeavingTiles )
        , ( 0, ResetMove )
        , ( fallDelay model moveType, SetFallingTiles )
        , ( 500, ShiftBoard )
        , ( 0, MakeNewTiles )
        , ( 500, ResetEntering )
        ]


fallDelay : Model -> MoveType -> Float
fallDelay model moveType =
    if List.length (model.currentMove) > 15 || moveType == Square then
        700
    else
        300
