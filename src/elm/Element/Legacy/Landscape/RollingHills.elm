module Element.Legacy.Landscape.RollingHills exposing
    ( Element
    , doubleLayer
    , element
    )

import Svg exposing (Svg)
import Svg.Attributes exposing (..)
import Utils.Html.Style as Style
import Utils.Svg exposing (..)
import Utils.Transform as Transform
import Window exposing (Window)


type alias Element msg =
    { angle : Float
    , adjustY : Float
    , element : Svg msg
    }


doubleLayer : Window -> ( String, List (Element msg) ) -> ( String, List (Element msg) ) -> Svg msg
doubleLayer =
    doubleLayerWithCurve_ 1


doubleLayerWithCurve_ curve window ( leftColor, leftElements ) ( rightColor, rightElements ) =
    Svg.g [ Style.transform [ Transform.translate 0 0 ] ]
        [ hillFullScreen window
            { color = leftColor
            , elements = leftElements
            , side = Left
            , curve = curve
            }
        , hillFullScreen window
            { color = rightColor
            , elements = rightElements
            , side = Right
            , curve = curve
            }
        ]


element : Float -> Float -> Svg msg -> Element msg
element =
    Element


type alias Hill msg =
    { color : String
    , elements : List (Element msg)
    , side : Side
    , curve : Float
    }


type Side
    = Left
    | Right


hillFullScreen : Window -> Hill msg -> Svg msg
hillFullScreen window hillConfig =
    let
        w =
            toFloat window.width

        h =
            toFloat window.height

        cx =
            sideToCx window hillConfig.side

        cy =
            h / 2

        r =
            w / hillConfig.curve

        elements =
            List.map (renderElement cx cy r) hillConfig.elements
    in
    Svg.svg
        [ viewBox_ 0 0 w 3000
        , width_ w
        , height_ 3000
        ]
        (hill hillConfig.color r cx cy :: elements)


renderElement : Float -> Float -> Float -> Element msg -> Svg msg
renderElement cx cy r elementConfig =
    let
        a =
            degrees <| elementConfig.angle - 90

        ( x, y ) =
            ( cx + r * cos a
            , cy + r * sin a
            )
    in
    translated x (y + r + elementConfig.adjustY) elementConfig.element


sideToCx : Window -> Side -> Float
sideToCx window side =
    case side of
        Left ->
            0

        Right ->
            toFloat window.width


hill : String -> Float -> Float -> Float -> Svg msg
hill color r cx cy =
    Svg.circle
        [ cx_ cx
        , cy_ cy
        , r_ r
        , fill color
        , Style.transform [ Transform.translateY r ]
        ]
        []
