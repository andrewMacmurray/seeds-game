module Views.Flowers.All exposing (renderFlower)

import Data.Board.Types exposing (SeedType(..))
import Svg exposing (Svg)
import Views.Flowers.Chrysanthemum as Chrysanthemum
import Views.Flowers.Cornflower as Cornflower
import Views.Flowers.Sunflower as Sunflower


renderFlower : SeedType -> Svg msg
renderFlower seedType =
    case seedType of
        Sunflower ->
            Sunflower.static

        Chrysanthemum ->
            Chrysanthemum.static

        Cornflower ->
            Cornflower.static

        _ ->
            Svg.g [] []
