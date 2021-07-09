module Element.Legacy.Landscape.SteepHills exposing
    ( Sprite
    , behind
    , inFront
    , layer
    )

import Axis2d
import Direction2d
import Geometry.Svg
import Html
import Point2d
import Svg exposing (Svg)
import Svg.Attributes exposing (..)
import Utils.Style as Style
import Utils.Svg exposing (..)
import Utils.Transform as Transform
import Window exposing (Window)


type alias Hill msg =
    ( String, List (Html.Attribute msg), List (Sprite msg) )


type alias Sprite msg =
    { placement : Placement
    , distanceX : Float
    , adjustY : Float
    , element : Svg msg
    }


type Placement
    = InFront
    | Behind


behind : Float -> Float -> Svg msg -> Sprite msg
behind =
    sprite Behind


inFront : Float -> Float -> Svg msg -> Sprite msg
inFront =
    sprite InFront


sprite : Placement -> Float -> Float -> Svg msg -> Sprite msg
sprite =
    Sprite


layer : Window -> Float -> Hill msg -> Hill msg -> Svg msg
layer window slope ( leftColor, leftStyles, leftElements ) ( rightColor, rightStyles, rightElements ) =
    let
        center =
            Point2d.pixels
                (toFloat window.width / 2)
                (toFloat window.height / 2)

        yAxis =
            Axis2d.withDirection Direction2d.y center
    in
    Svg.g [ Style.transform [ Transform.translate 0 0 ] ]
        [ hillFullScreen window slope leftColor leftStyles leftElements
        , Geometry.Svg.mirrorAcross yAxis (hillFullScreen window slope rightColor rightStyles rightElements)
        ]


hillFullScreen : Window -> Float -> String -> List (Html.Attribute msg) -> List (Sprite msg) -> Svg msg
hillFullScreen window slope color hillStyles elements =
    Svg.svg
        [ y_ (toFloat window.height / 2)
        , x_ 0
        , width_ 1000
        , height_ 1200
        , viewBox_ 0 0 100 100
        ]
        (renderHill slope elements (hill color hillStyles))


renderHill : Float -> List (Sprite msg) -> (Float -> Svg msg) -> List (Svg msg)
renderHill slope elements hill_ =
    elements
        |> List.partition (\{ placement } -> placement == Behind)
        |> (\( elementsBehind, elementsInFront ) ->
                List.concat
                    [ List.map (renderHillElement slope) elementsBehind
                    , [ hill_ slope ]
                    , List.map (renderHillElement slope) elementsInFront
                    ]
           )


renderHillElement : Float -> Sprite msg -> Svg msg
renderHillElement slope el =
    translated el.distanceX ((el.distanceX * slope) - el.adjustY) el.element


hill : String -> List (Html.Attribute msg) -> Float -> Svg msg
hill color styles slope =
    Svg.polygon
        (List.append styles
            [ fill color
            , points_
                [ point 0 0
                , point 0 100
                , point (100 / slope) 100
                ]
            ]
        )
        []
