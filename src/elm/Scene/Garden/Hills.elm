module Scene.Garden.Hills exposing (..)

import Config.World as Worlds
import Context exposing (Context)
import Scene.Garden.Chrysanthemum as Chrysanthemum
import Scene.Garden.Shape as Shape
import Scene.Garden.Sunflower as Sunflower
import Svg exposing (Svg)
import Utils.Svg as Svg


view : Context -> Svg msg
view context =
    Svg.svg
        [ Svg.viewBox_ 0 0 (toFloat context.window.width) (toFloat context.window.height * toFloat (List.length Worlds.list))
        ]
        [ Chrysanthemum.hills context.window
            |> Shape.moveDown (toFloat context.window.height)
            |> Shape.view context.window
        , Sunflower.hills context.window
            |> Shape.moveDown (toFloat context.window.height * 2)
            |> Shape.view context.window
        ]
