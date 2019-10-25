module Views.Flowers.All exposing (renderFlower)

import Seed exposing (Seed(..))
import Svg exposing (Svg)
import Views.Flowers.Chrysanthemum as Chrysanthemum
import Views.Flowers.Cornflower as Cornflower
import Views.Flowers.Sunflower as Sunflower


renderFlower : Seed -> Svg msg
renderFlower seed =
    case seed of
        Sunflower ->
            Sunflower.static

        Chrysanthemum ->
            Chrysanthemum.static

        Cornflower ->
            Cornflower.static

        _ ->
            Svg.g [] []
