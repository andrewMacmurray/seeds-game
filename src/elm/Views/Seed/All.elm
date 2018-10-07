module Views.Seed.All exposing (renderSeed)

import Data.Board.Types exposing (..)
import Svg exposing (Svg)
import Views.Seed.Circle exposing (foxglove)
import Views.Seed.Mono exposing (greyedOut, rose)
import Views.Seed.Twin exposing (lupin, marigold, sunflower)


renderSeed : SeedType -> Svg msg
renderSeed seedType =
    case seedType of
        Sunflower ->
            sunflower

        Foxglove ->
            foxglove

        Lupin ->
            lupin

        Rose ->
            rose

        Marigold ->
            marigold

        GreyedOut ->
            greyedOut
