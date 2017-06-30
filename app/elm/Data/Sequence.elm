module Data.Sequence exposing (..)

import Delay exposing (withUnit)
import Model exposing (..)
import Time exposing (millisecond, Time)


growSeedPods : List ( Float, Time, Msg )
growSeedPods =
    withUnit millisecond
        [ ( 0, SetGrowingSeedPods )
        , ( 0, ResetMove )
        , ( 800, GrowPodsToSeeds )
        , ( 600, ResetGrowingSeeds )
        ]


removeTiles : Model -> MoveType -> List ( Float, Time, Msg )
removeTiles model moveType =
    withUnit millisecond
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
