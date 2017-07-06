module Data.Sequence exposing (..)

import Delay exposing (withUnit, sequence)
import Model exposing (..)
import Time exposing (millisecond, Time)


growSeedPodsSequence : Cmd Msg
growSeedPodsSequence =
    sequence <|
        withUnit millisecond
            [ ( 0, SetGrowingSeedPods )
            , ( 0, ResetMove )
            , ( 800, GrowPodsToSeeds )
            , ( 600, ResetGrowingSeeds )
            ]


removeTilesSequence : Model -> MoveShape -> Cmd Msg
removeTilesSequence model moveShape =
    sequence <|
        withUnit millisecond
            [ ( 0, SetLeavingTiles )
            , ( 0, ResetMove )
            , ( fallDelay model moveShape, SetFallingTiles )
            , ( 500, ShiftBoard )
            , ( 0, MakeNewTiles )
            , ( 500, ResetEntering )
            ]


fallDelay : Model -> MoveShape -> Float
fallDelay model moveShape =
    if moveShape == Square then
        700
    else
        300
