module View.Flower exposing (view)

import Seed exposing (Seed(..))
import Svg exposing (Svg)
import View.Flower.Chrysanthemum as Chrysanthemum
import View.Flower.Cornflower as Cornflower
import View.Flower.Sunflower as Sunflower


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
