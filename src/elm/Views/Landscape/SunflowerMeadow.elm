module Views.Landscape.SunflowerMeadow exposing
    ( Visibility(..)
    , animated
    )

import Css.Color as Color
import Css.Style as Style
import Css.Transform as Transform
import Css.Transition as Transition
import Data.Window as Window exposing (Window)
import Helpers.Svg exposing (..)
import Svg exposing (Attribute, Svg)
import Svg.Attributes exposing (..)


type Visibility
    = Hidden
    | Visible


animated : Window -> Visibility -> Svg msg
animated window visibility =
    Svg.svg
        [ viewBox_ 0 0 window.width window.height
        ]
        [ Svg.g
            [ Style.svgStyles
                [ Style.transform [ Transform.translateY <| toFloat <| bigHillVisibilityOffset window visibility ]
                , Transition.transitionAll 3000 [ Transition.delay 500, Transition.easeOut ]
                ]
            ]
            [ bigHill window ]
        , hills ( Color.seaGreen, Color.deepPine ) -100 window visibility 0
        , hills ( Color.meadowGreen, Color.darkSeaGreen ) 100 window visibility 500
        ]


bigHillVisibilityOffset : Window -> Visibility -> Int
bigHillVisibilityOffset window visibility =
    case visibility of
        Hidden ->
            window.height

        Visible ->
            50


hills : ( Color.Color, Color.Color ) -> Int -> Window -> Visibility -> Int -> Svg msg
hills ( colorLeft, colorRight ) y window visibility delay =
    Svg.g
        [ Style.svgStyles
            [ Style.transform [ Transform.translateY <| toFloat <| hillsVisibilityOffset window visibility y ]
            , Transition.transitionAll 3000 [ Transition.delay delay, Transition.easeOut ]
            ]
        ]
        [ hill colorLeft 0 window
        , hill colorRight window.width window
        ]


hillsVisibilityOffset : Window -> Visibility -> Int -> Int
hillsVisibilityOffset window visibility mainOffset =
    case visibility of
        Hidden ->
            window.height // 2

        Visible ->
            mainOffset


bigHill : Window -> Svg msg
bigHill window =
    let
        size =
            toFloat <| Window.smallestDimension window // 2 + 400
    in
    Svg.circle
        [ r_ size
        , cx_ <| toFloat <| window.width // 2
        , cy_ size
        , fill Color.darkForestGreen
        ]
        []


hill : Color.Color -> Int -> Window -> Svg msg
hill color x window =
    let
        w =
            toFloat <| window.width // 2 + hillOffset window
    in
    Svg.circle
        [ cx_ <| toFloat x
        , cy_ <| toFloat <| window.height // 2
        , r_ w
        , fill color
        , Style.svgStyles [ Style.transform [ Transform.translateY w ] ]
        ]
        []


hillOffset : Window -> Int
hillOffset window =
    case Window.size window of
        Window.Small ->
            100

        Window.Medium ->
            450

        Window.Large ->
            600
