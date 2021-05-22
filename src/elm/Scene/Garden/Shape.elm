module Scene.Garden.Shape exposing (..)

import Circle2d exposing (Circle2d)
import Element exposing (Color)
import Geometry.Svg as Svg
import Pixels exposing (Pixels)
import Polygon2d exposing (Polygon2d)
import Svg
import Utils.Geometry as Geometry
import Utils.Svg as Svg
import Window exposing (Window)



-- Shape


type Shape
    = Polygon Polygon_
    | Circle Circle_
    | Group (List Shape)


type alias Polygon_ =
    { shape : Polygon2d Pixels Coords
    , fill : Color
    , mirror : Bool
    }


type alias Circle_ =
    { shape : Circle2d Pixels Coords
    , fill : Color
    , mirror : Bool
    }


type alias Coords =
    ()



-- Construct


group : List Shape -> Shape
group =
    Group


polygon : { fill : Color } -> Polygon2d Pixels Coords -> Shape
polygon { fill } p =
    Polygon
        { shape = p
        , fill = fill
        , mirror = False
        }


circle : { fill : Color } -> Circle2d Pixels Coords -> Shape
circle { fill } c =
    Circle
        { shape = c
        , fill = fill
        , mirror = False
        }



-- Update


mirror : Shape -> Shape
mirror shape =
    case shape of
        Polygon p ->
            Polygon { p | mirror = True }

        Circle c ->
            Circle { c | mirror = True }

        Group shapes ->
            Group (List.map mirror shapes)


moveDown : Float -> Shape -> Shape
moveDown y shape =
    case shape of
        Polygon p ->
            Polygon { p | shape = Polygon2d.translateBy (Geometry.down y) p.shape }

        Circle c ->
            Circle { c | shape = Circle2d.translateBy (Geometry.down y) c.shape }

        Group shapes ->
            Group (List.map (moveDown y) shapes)



-- View


view : Window -> Shape -> Svg.Svg msg
view window shape =
    case shape of
        Polygon p ->
            withMirror p window (Svg.polygon2d [ Svg.fill_ p.fill ] p.shape)

        Circle c ->
            withMirror c window (Svg.circle2d [ Svg.fill_ c.fill ] c.shape)

        Group shapes ->
            Svg.g [] (List.map (view window) shapes)


withMirror : { a | mirror : Bool } -> Window -> Svg.Svg msg -> Svg.Svg msg
withMirror options window s =
    if options.mirror then
        Geometry.mirror window s

    else
        s
