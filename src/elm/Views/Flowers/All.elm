module Views.Flowers.All exposing (renderFlower)

import Board.Tile as Tile exposing (SeedType(..))
import Svg exposing (Svg)
import Views.Flowers.Chrysanthemum as Chrysanthemum
import Views.Flowers.Cornflower as Cornflower
import Views.Flowers.Sunflower as Sunflower


renderFlower : Tile.SeedType -> Svg msg
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
