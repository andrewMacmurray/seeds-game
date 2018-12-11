module Views.Landscape.RollingHills exposing
    ( Element
    , doubleLayer
    , element
    )

import Css.Color exposing (Color)
import Css.Style as Style
import Css.Transform as Transform
import Data.Window as Window exposing (Window)
import Helpers.Svg exposing (..)
import Svg exposing (Svg)
import Svg.Attributes exposing (..)
import Views.Flowers.Sunflower as Sunflower


type alias Element msg =
    { angle : Float
    , adjustY : Float
    , element : Svg msg
    }


doubleLayer : Window -> ( Color, List (Element msg) ) -> ( Color, List (Element msg) ) -> Svg msg
doubleLayer window ( leftColor, leftElements ) ( rightColor, rightElements ) =
    Svg.g []
        [ hillFullScreen window
            { color = leftColor
            , elements = leftElements
            , side = Left
            }
        , hillFullScreen window
            { color = rightColor
            , elements = rightElements
            , side = Right
            }
        ]


element : Float -> Float -> Svg msg -> Element msg
element =
    Element


type alias Hill msg =
    { color : Color
    , elements : List (Element msg)
    , side : Side
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
            w

        elements =
            List.map (renderElement cx cy r) hillConfig.elements
    in
    Svg.svg
        [ viewBox_ 0 0 w 3000
        , width_ w
        , height_ 3000
        ]
        [ Svg.g [] <| [ hill hillConfig.color r cx cy ] ++ elements
        ]


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
            toFloat <| window.width


hill : Color -> Float -> Float -> Float -> Svg msg
hill color r cx cy =
    Svg.circle
        [ cx_ cx
        , cy_ cy
        , r_ r
        , fill color
        , Style.svgStyles [ Style.transform [ Transform.translateY r ] ]
        ]
        []
