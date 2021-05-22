module Scene.Garden.Hills exposing (..)

import Config.Level as Level
import Config.World as Worlds
import Context exposing (Context)
import Level.Progress as Progress
import Scene.Garden.Chrysanthemum as Chrysanthemum
import Scene.Garden.Cornflower as Cornflower
import Scene.Garden.Shape as Shape
import Scene.Garden.Sunflower as Sunflower
import Seed
import Svg exposing (Svg)
import Utils.Svg as Svg
import Window exposing (vh, vw)


view : Context -> Svg msg
view ({ window } as context) =
    let
        h =
            vh window

        w =
            vw window
    in
    Svg.svg
        [ Svg.viewBox_ 0 0 w (h * toFloat (List.length Worlds.list))
        ]
        (Worlds.list
            |> List.reverse
            |> List.indexedMap (toHills context)
        )


toHills : Context -> Int -> Level.WorldWithLevels -> Svg msg
toHills context index { world, levels } =
    if Progress.worldComplete levels context.progress then
        getHill context.window world.seed
            |> Shape.moveDown (toFloat index * vh context.window)
            |> Shape.view context.window

    else
        Svg.g [] []


getHill window seed =
    case seed of
        Seed.Sunflower ->
            Sunflower.hills window

        Seed.Chrysanthemum ->
            Chrysanthemum.hills window

        Seed.Cornflower ->
            Cornflower.hills window

        _ ->
            Sunflower.hills window
