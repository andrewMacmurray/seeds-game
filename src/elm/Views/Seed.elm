module Views.Seed exposing (view)

import Seed exposing (Seed(..))
import Svg exposing (Svg)
import Views.Seed.Circle exposing (chrysanthemum)
import Views.Seed.Mono exposing (rose)
import Views.Seed.Twin exposing (cornflower, lupin, marigold, sunflower)


view : Seed -> Svg msg
view seed =
    case seed of
        Sunflower ->
            sunflower

        Chrysanthemum ->
            chrysanthemum

        Cornflower ->
            cornflower

        Lupin ->
            lupin

        Rose ->
            rose

        Marigold ->
            marigold
