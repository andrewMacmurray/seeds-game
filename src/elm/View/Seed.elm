module View.Seed exposing (view)

import Seed exposing (Seed(..))
import Svg exposing (Svg)
import View.Seed.Circle exposing (chrysanthemum)
import View.Seed.Mono exposing (rose)
import View.Seed.Twin exposing (cornflower, lupin, marigold, sunflower)


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
