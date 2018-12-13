module Views.Landscape.SteepHills exposing
    ( Element
    , behind
    , inFront
    , layer
    )

import Axis2d
import Css.Color exposing (Color)
import Css.Style as Style exposing (Style)
import Css.Transform as Transform
import Data.Window exposing (Window)
import Direction2d
import Geometry.Svg
import Helpers.Svg exposing (..)
import Point2d
import Svg exposing (Svg)
import Svg.Attributes exposing (..)


type alias Hill msg =
    ( Color, List Style, List (Element msg) )


type alias Element msg =
    { placement : Placement
    , distanceX : Float
    , adjustY : Float
    , element : Svg msg
    }


type Placement
    = InFront
    | Behind


behind : Float -> Float -> Svg msg -> Element msg
behind =
    element Behind


inFront : Float -> Float -> Svg msg -> Element msg
inFront =
    element InFront


element : Placement -> Float -> Float -> Svg msg -> Element msg
element =
    Element


layer : Window -> Float -> Hill msg -> Hill msg -> Svg msg
layer window slope ( leftColor, leftStyles, leftElements ) ( rightColor, rightStyles, rightElements ) =
    let
        center =
            Point2d.fromCoordinates
                ( toFloat window.width / 2
                , toFloat window.height / 2
                )

        yAxis =
            Axis2d.withDirection Direction2d.y center
    in
    Svg.g []
        [ hillFullScreen window slope leftColor leftStyles leftElements
        , Geometry.Svg.mirrorAcross yAxis <| hillFullScreen window slope rightColor rightStyles rightElements
        ]


hillFullScreen : Window -> Float -> Color -> List Style -> List (Element msg) -> Svg msg
hillFullScreen window slope color hillStyles elements =
    Svg.svg
        [ y_ <| toFloat window.height / 2
        , x_ 0
        , width_ 1000
        , height_ 1200
        , viewBox_ 0 0 100 100
        ]
    <|
        renderHill slope elements (hill color hillStyles)


renderHill : Float -> List (Element msg) -> (Float -> Svg msg) -> List (Svg msg)
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


renderHillElement : Float -> Element msg -> Svg msg
renderHillElement slope el =
    translated el.distanceX ((el.distanceX * slope) - el.adjustY) el.element


hill : Color -> List Style -> Float -> Svg msg
hill color styles slope =
    Svg.polygon
        [ fill color
        , Style.svgStyles styles
        , points_
            [ point 0 0
            , point 0 100
            , point (100 / slope) 100
            ]
        ]
        []
