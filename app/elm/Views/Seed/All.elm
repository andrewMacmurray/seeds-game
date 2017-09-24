module Views.Seed.All exposing (..)

import Html exposing (Html)
import Data.Level.Types exposing (..)
import Views.Seed.Circle exposing (foxglove)
import Views.Seed.Mono exposing (greyedOut, rose)
import Views.Seed.Twin exposing (lupin, marigold, sunflower)


renderSeed : SeedType -> Html msg
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
