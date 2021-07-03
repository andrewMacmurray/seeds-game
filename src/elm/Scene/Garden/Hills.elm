module Scene.Garden.Hills exposing (bottomOffset, view)

import Context exposing (Context)
import Element.Scale as Scale
import Game.Config.Level as Level
import Game.Config.World as Worlds
import Game.Level.Progress as Progress exposing (Progress)
import Geometry.Shape as Shape exposing (Shape)
import Scene.Garden.Chrysanthemum as Chrysanthemum
import Scene.Garden.Cornflower as Cornflower
import Scene.Garden.Sunflower as Sunflower
import Seed exposing (Seed)
import Svg exposing (Svg)
import Utils.Svg as Svg
import Window exposing (Window, vh, vw)



-- Offset


bottomOffset : number
bottomOffset =
    Scale.large



-- View


view : Context -> Svg msg
view context =
    Svg.svg [ viewBox context.window ]
        (Worlds.list
            |> List.reverse
            |> List.indexedMap (toHills context)
        )


viewBox : Window -> Svg.Attribute msg
viewBox window =
    Svg.viewBox_ 0 0 (vw window) (viewBoxHeight window)


viewBoxHeight : Window -> Float
viewBoxHeight window =
    vh window * toFloat (List.length Worlds.list) + bottomOffset


toHills : Context -> Int -> Level.WorldWithLevels -> Svg msg
toHills context index { world, levels } =
    getHill context.window world.seed
        |> Shape.moveDown (toFloat index * vh context.window)
        |> Shape.hideIf (isIncomplete levels context.progress)
        |> Shape.view context.window


isIncomplete : List Level.Id -> Progress -> Bool
isIncomplete levels =
    Progress.worldIsCompleted levels >> not


getHill : Window -> Seed -> Shape msg
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
