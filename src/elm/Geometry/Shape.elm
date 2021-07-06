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
    , placeAt
    , polygon
    , view
    )

import Circle2d exposing (Circle2d)
import Element exposing (Color)
import Frame2d
import Geometry.Svg as Svg
import Pixels exposing (Pixels)
import Point2d exposing (Point2d)
import Polygon2d exposing (Polygon2d)
import Simple.Animation exposing (Animation)
import Svg exposing (Svg)
import Utils.Animated as Animated
import Utils.Geometry as Geometry
import Utils.Svg as Svg
import Window exposing (Window)



-- Shape


type Shape msg
    = Polygon Polygon_
    | Circle Circle_
    | Placed (Placed_ msg)
    | Group (List (Shape msg))


type alias Placed_ msg =
    { svg : Svg msg
    , point : Point2d Pixels Coords
    , attributes : Attributes
    }


type alias Polygon_ =
    Shape_ (Polygon2d Pixels Coords)


type alias Circle_ =
    Shape_ (Circle2d Pixels Coords)


type alias Shape_ shape =
    { shape : shape
    , attributes : Attributes
    }


type alias Attributes =
    { fill : Maybe Color
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


group : List (Shape msg) -> Shape msg
group =
    Group


polygon : Options -> Polygon2d Pixels Coords -> Shape msg
polygon options shape_ =
    Polygon
        { shape = shape_
        , attributes = defaults options
        }


circle : Options -> Circle2d Pixels Coords -> Shape msg
circle options shape_ =
    Circle
        { shape = shape_
        , attributes = defaults options
        }


placeAt : Point2d Pixels Coords -> Svg msg -> Shape msg
placeAt point svg =
    Placed
        { point = point
        , svg = svg
        , attributes = defaults_
        }


defaults : Options -> Attributes
defaults options =
    { defaults_ | fill = Just options.fill }


defaults_ : Attributes
defaults_ =
    { fill = Nothing
    , mirror = False
    , hide = False
    , animation = Nothing
    }



-- Customise


mirror : Shape msg -> Shape msg
mirror =
    update (\a -> { a | mirror = True })


hideIf : Bool -> Shape msg -> Shape msg
hideIf condition =
    if condition then
        hide

    else
        identity


hide : Shape msg -> Shape msg
hide =
    update (\a -> { a | hide = True })


animate : Animation -> Shape msg -> Shape msg
animate animation =
    update (\a -> { a | animation = Just animation })


moveUp : Float -> Shape msg -> Shape msg
moveUp y =
    moveDown -y


moveDown : Float -> Shape msg -> Shape msg
moveDown y shape =
    case shape of
        Polygon shape_ ->
            Polygon { shape_ | shape = Polygon2d.translateBy (Geometry.down y) shape_.shape }

        Circle shape_ ->
            Circle { shape_ | shape = Circle2d.translateBy (Geometry.down y) shape_.shape }

        Group shapes ->
            Group (List.map (moveDown y) shapes)

        Placed shape_ ->
            Placed { shape_ | point = Point2d.translateBy (Geometry.down y) shape_.point }


update : (Attributes -> Attributes) -> Shape msg -> Shape msg
update f shape =
    case shape of
        Polygon p ->
            Polygon (update_ f p)

        Circle c ->
            Circle (update_ f c)

        Group shapes ->
            Group (List.map (update f) shapes)

        Placed x ->
            Placed (update_ f x)


update_ : (Attributes -> Attributes) -> { a | attributes : Attributes } -> { a | attributes : Attributes }
update_ f shape_ =
    { shape_ | attributes = f shape_.attributes }



-- View


fullScreen : Window -> Shape msg -> Svg msg
fullScreen window_ shape =
    Svg.window window_ [ Svg.translate0 ] (view window_ shape)


view : Window -> Shape msg -> List (Svg msg)
view window_ shape =
    case shape of
        Polygon shape_ ->
            [ Svg.polygon2d [ fill shape_ ] shape_.shape
                |> applyMirror shape_ window_
                |> applyHidden shape_
                |> applyAnimation shape_
            ]

        Circle shape_ ->
            [ Svg.circle2d [ fill shape_ ] shape_.shape
                |> applyMirror shape_ window_
                |> applyHidden shape_
                |> applyAnimation shape_
            ]

        Group shapes ->
            List.concatMap (view window_) shapes

        Placed placed_ ->
            [ Svg.placeIn (Frame2d.atPoint placed_.point) placed_.svg
                |> applyMirror placed_ window_
                |> applyHidden placed_
                |> applyAnimation placed_
            ]


fill : Shape_ shape -> Svg.Attribute msg
fill shape =
    shape.attributes.fill
        |> Maybe.map Svg.fill_
        |> Maybe.withDefault Svg.empty


applyMirror : { shape | attributes : Attributes } -> Window -> Svg msg -> Svg msg
applyMirror shape_ window_ s =
    if shape_.attributes.mirror then
        Geometry.mirror window_ s

    else
        s


applyHidden : { shape | attributes : Attributes } -> Svg msg -> Svg msg
applyHidden shape_ s =
    if shape_.attributes.hide then
        Svg.g_ [] []

    else
        s


applyAnimation : { shape | attributes : Attributes } -> Svg msg -> Svg msg
applyAnimation shape_ s =
    case shape_.attributes.animation of
        Just anim ->
            Animated.g anim [] [ s ]

        Nothing ->
            s
