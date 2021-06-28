module Geometry.Shape exposing
    ( Shape
    , animate
    , circle
    , fullScreen
    , group
    , hideIf
    , mirror
    , moveDown
    , moveUp
    , polygon
    , view
    )

import Circle2d exposing (Circle2d)
import Element exposing (Color)
import Geometry.Svg as Svg
import Pixels exposing (Pixels)
import Polygon2d exposing (Polygon2d)
import Simple.Animation exposing (Animation)
import Svg exposing (Svg)
import Utils.Animated as Animated
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
    , animation : Maybe Animation
    }


type alias Options =
    { fill : Color
    }


type alias Coords =
    ()



-- Construct


group : List Shape -> Shape
group =
    Group


polygon : Options -> Polygon2d Pixels Coords -> Shape
polygon options shape_ =
    Polygon
        { shape = shape_
        , attributes = defaults options
        }


circle : Options -> Circle2d Pixels Coords -> Shape
circle options shape_ =
    Circle
        { shape = shape_
        , attributes = defaults options
        }


defaults : Options -> Attributes
defaults options =
    { fill = options.fill
    , mirror = False
    , hide = False
    , animation = Nothing
    }



-- Customise


mirror : Shape -> Shape
mirror =
    update (\a -> { a | mirror = True })


hideIf : Bool -> Shape -> Shape
hideIf condition =
    if condition then
        hide

    else
        identity


hide : Shape -> Shape
hide =
    update (\a -> { a | hide = True })


animate : Animation -> Shape -> Shape
animate animation =
    update (\a -> { a | animation = Just animation })


moveUp : Float -> Shape -> Shape
moveUp y =
    moveDown -y


moveDown : Float -> Shape -> Shape
moveDown y shape =
    case shape of
        Polygon shape_ ->
            Polygon { shape_ | shape = Polygon2d.translateBy (Geometry.down y) shape_.shape }

        Circle shape_ ->
            Circle { shape_ | shape = Circle2d.translateBy (Geometry.down y) shape_.shape }

        Group shapes ->
            Group (List.map (moveDown y) shapes)


update : (Attributes -> Attributes) -> Shape -> Shape
update f shape =
    case shape of
        Polygon p ->
            Polygon (update_ f p)

        Circle c ->
            Circle (update_ f c)

        Group shapes ->
            Group (List.map (update f) shapes)


update_ : (Attributes -> Attributes) -> Shape_ shape -> Shape_ shape
update_ f shape_ =
    { shape_ | attributes = f shape_.attributes }



-- View


fullScreen : Window -> Shape -> Svg msg
fullScreen window_ shape =
    Svg.window window_ [] [ view window_ shape ]


view : Window -> Shape -> Svg msg
view window_ shape =
    case shape of
        Polygon shape_ ->
            Svg.polygon2d [ fill shape_ ] shape_.shape
                |> applyMirror shape_ window_
                |> applyHidden shape_
                |> applyAnimation shape_

        Circle shape_ ->
            Svg.circle2d [ fill shape_ ] shape_.shape
                |> applyMirror shape_ window_
                |> applyHidden shape_
                |> applyAnimation shape_

        Group shapes ->
            Svg.g [] (List.map (view window_) shapes)


fill : Shape_ shape -> Svg.Attribute msg
fill shape =
    Svg.fill_ shape.attributes.fill


applyMirror : Shape_ shape -> Window -> Svg msg -> Svg msg
applyMirror shape_ window_ s =
    if shape_.attributes.mirror then
        Geometry.mirror window_ s

    else
        s


applyHidden : Shape_ shape -> Svg msg -> Svg msg
applyHidden shape_ s =
    if shape_.attributes.hide then
        Svg.g [] []

    else
        s


applyAnimation : Shape_ shape -> Svg msg -> Svg msg
applyAnimation shape_ s =
    case shape_.attributes.animation of
        Just anim ->
            Animated.g anim [] [ s ]

        Nothing ->
            s
