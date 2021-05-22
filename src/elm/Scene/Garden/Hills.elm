module Scene.Garden.Hills exposing (..)

import Config.World as Worlds
import Context exposing (Context)
import Scene.Garden.Chrysanthemum as Chrysanthemum
import Scene.Garden.Cornflower as Cornflower
import Scene.Garden.Shape as Shape
import Scene.Garden.Sunflower as Sunflower
import Svg exposing (Svg)
import Utils.Svg as Svg
import Window exposing (vh, vw)


view : Context -> Svg msg
view { window } =
    let
        h =
            vh window

        w =
            vw window
    in
    Svg.svg
        [ Svg.viewBox_ 0 0 w (h * toFloat (List.length Worlds.list))
        ]
        [ Cornflower.hills window
            |> Shape.moveDown 0
            |> Shape.view window
        , Chrysanthemum.hills window
            |> Shape.moveDown h
            |> Shape.view window
        , Sunflower.hills window
            |> Shape.moveDown (h * 2)
            |> Shape.view window
        ]
