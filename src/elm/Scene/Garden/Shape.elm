module Scene.Garden.Shape exposing
    ( Shape
    , circle
    , group
    , hideIf
    , mirror
    , moveDown
    , polygon
    , view
    )

import Circle2d exposing (Circle2d)
import Element exposing (Color)
import Geometry.Svg as Svg
import Pixels exposing (Pixels)
import Polygon2d exposing (Polygon2d)
import Svg exposing (Svg)
import Utils.Geometry as Geometry
import Utils.Svg as Svg
import Window exposing (Window)



-- Shape


type Shape
    = Polygon Polygon_
    | Circle Circle_
    | Group (List Shape)


type alias Polygon_ =
    Shape_ (Polygon2d Pixels Coords)


type alias Circle_ =
    Shape_ (Circle2d Pixels Coords)


type alias Shape_ shape =
    { shape : shape
    , attributes : Attributes
    }


type alias Attributes =
    { fill : Color
    , mirror : Bool
    , hide : Bool
    }


type alias Coords =
    ()



-- Construct


group : List Shape -> Shape
group =
    Group


polygon : { fill : Color } -> Polygon2d Pixels Coords -> Shape
polygon options p =
    Polygon
        { shape = p
        , attributes = defaultAttributes options
        }


circle : { fill : Color } -> Circle2d Pixels Coords -> Shape
circle options c =
    Circle
        { shape = c
        , attributes = defaultAttributes options
        }


defaultAttributes : { fill : Color } -> Attributes
defaultAttributes options =
    { fill = options.fill
    , mirror = False
    , hide = False
    }



-- Update


mirror : Shape -> Shape
mirror =
    updateAttributes (\a -> { a | mirror = True })


hideIf : Bool -> Shape -> Shape
hideIf condition =
    if condition then
        hide

    else
        identity


hide : Shape -> Shape
hide =
    updateAttributes (\a -> { a | hide = True })


moveDown : Float -> Shape -> Shape
moveDown y shape =
    case shape of
        Polygon p ->
            Polygon { p | shape = Polygon2d.translateBy (Geometry.down y) p.shape }

        Circle c ->
            Circle { c | shape = Circle2d.translateBy (Geometry.down y) c.shape }

        Group shapes ->
            Group (List.map (moveDown y) shapes)


updateAttributes : (Attributes -> Attributes) -> Shape -> Shape
updateAttributes f shape =
    case shape of
        Polygon p ->
            Polygon (updateAttributes_ f p)

        Circle c ->
            Circle (updateAttributes_ f c)

        Group shapes ->
            Group (List.map (updateAttributes f) shapes)


updateAttributes_ : (Attributes -> Attributes) -> Shape_ shape -> Shape_ shape
updateAttributes_ f shape =
    { shape | attributes = f shape.attributes }



-- View


view : Window -> Shape -> Svg.Svg msg
view window shape =
    case shape of
        Polygon p ->
            Svg.polygon2d [ fill p ] p.shape
                |> withMirror p window
                |> applyHidden p

        Circle c ->
            Svg.circle2d [ fill c ] c.shape
                |> withMirror c window
                |> applyHidden c

        Group shapes ->
            Svg.g [] (List.map (view window) shapes)


fill : Shape_ shape -> Svg.Attribute msg
fill shape =
    Svg.fill_ shape.attributes.fill


withMirror : Shape_ shape -> Window -> Svg msg -> Svg msg
withMirror shape window s =
    if shape.attributes.mirror then
        Geometry.mirror window s

    else
        s


applyHidden : Shape_ shape -> Svg msg -> Svg msg
applyHidden shape s =
    if shape.attributes.hide then
        Svg.g [] []

    else
        s
