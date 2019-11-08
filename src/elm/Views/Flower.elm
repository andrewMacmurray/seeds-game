module Views.Flower exposing (view)

import Seed exposing (Seed(..))
import Svg exposing (Svg)
import Views.Flower.Chrysanthemum as Chrysanthemum
import Views.Flower.Cornflower as Cornflower
import Views.Flower.Sunflower as Sunflower


view : Seed -> Svg msg
view seed =
    case seed of
        Sunflower ->
            Sunflower.static

        Chrysanthemum ->
            Chrysanthemum.static

        Cornflower ->
            Cornflower.static

        _ ->
            Svg.g [] []
