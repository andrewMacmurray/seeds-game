module Scene.Level.Board.Tile.Stroke exposing
    ( darker
    , lighter
    , thickness
    )

import Board.Tile as Tile exposing (Tile)
import Element exposing (Color)
import Element.Palette as Color
import Scene.Level.Board.Tile.Scale as Scale
import Seed exposing (Seed)
import Window exposing (Window)



-- Size


thickness : Window -> Float
thickness window =
    6 * Scale.factor window



-- Darker


darker : Tile -> Color
darker tile =
    case tile of
        Tile.Rain ->
            Color.blue6

        Tile.Sun ->
            Color.gold

        Tile.SeedPod ->
            Color.lime5

        Tile.Seed seed ->
            darkerSeed seed

        Tile.Burst tile_ ->
            darkerBurst tile_


darkerSeed : Seed -> Color
darkerSeed seed =
    case seed of
        Seed.Sunflower ->
            Color.darkBrown

        Seed.Chrysanthemum ->
            Color.mauve4

        Seed.Cornflower ->
            Color.blue2

        Seed.Lupin ->
            Color.crimson

        _ ->
            Color.darkBrown


darkerBurst : Maybe Tile -> Color
darkerBurst =
    Maybe.map darker >> Maybe.withDefault Color.greyYellow



-- Lighter


lighter : Tile -> Color
lighter tile =
    case tile of
        Tile.Rain ->
            Element.rgb255 171 238 237

        Tile.Sun ->
            Element.rgb255 249 221 79

        Tile.SeedPod ->
            Element.rgb255 157 229 106

        Tile.Seed seed ->
            lighterSeed seed

        Tile.Burst tile_ ->
            lighterBurst tile_


lighterBurst : Maybe Tile -> Color
lighterBurst =
    Maybe.map lighter >> Maybe.withDefault Color.transparent


lighterSeed : Seed -> Color
lighterSeed seed =
    case seed of
        Seed.Sunflower ->
            Color.lightBrown

        Seed.Chrysanthemum ->
            Color.orange

        Seed.Cornflower ->
            Color.blueGrey

        Seed.Lupin ->
            Color.brown

        _ ->
            Color.lightBrown
