module Views.Landscape.SteepHills exposing
    ( Element
    , Placement
    , behind
    , element
    , inFront
    , layer
    )

import Axis2d
import Css.Color as Color
import Css.Style as Style
import Css.Transform as Transform
import Data.Window exposing (Window)
import Direction2d
import Geometry.Svg
import Helpers.Svg exposing (..)
import Point2d
import Svg
import Svg.Attributes exposing (..)


layer window slope ( leftColor, leftStyles, leftElements ) ( rightColor, rightStyles, rightElements ) =
    let
        center =
            Point2d.fromCoordinates
                ( toFloat <| window.width // 2
                , toFloat <| window.height // 2
                )

        yAxis =
            Axis2d.withDirection Direction2d.y center
    in
    Svg.g []
        [ hillFullScreen window slope leftColor leftStyles leftElements
        , Geometry.Svg.mirrorAcross yAxis <| hillFullScreen window slope rightColor rightStyles rightElements
        ]


hillFullScreen window slope color hillStyles elements =
    Svg.svg
        [ y_ <| toFloat <| window.height // 2
        , x_ 0
        , width_ 1000
        , height_ 1200
        , viewBox_ 0 0 100 100
        ]
    <|
        renderHill slope elements (hill color hillStyles)


renderHill slope elements hl =
    elements
        |> List.partition (\el -> el.placement == Behind)
        |> (\( a, b ) ->
                List.concat
                    [ List.map (renderHillElement slope) a
                    , [ hl slope ]
                    , List.map (renderHillElement slope) b
                    ]
           )


behind =
    element Behind


inFront =
    element InFront


type alias Element msg =
    { placement : Placement
    , distanceX : Float
    , adjustY : Float
    , element : Svg.Svg msg
    }


type Placement
    = InFront
    | Behind


element =
    Element


renderHillElement slope el =
    withOffset el.distanceX ((el.distanceX * slope) - el.adjustY) [ el.element ]


withOffset x y =
    Svg.g [ Style.svgStyles [ Style.transform [ Transform.translate x y ] ] ]


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
