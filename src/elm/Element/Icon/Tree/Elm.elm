module Element.Icon.Tree.Elm exposing (alive)

import Element exposing (Color)
import Element.Palette as Palette
import Svg exposing (Svg)
import Svg.Attributes exposing (..)
import Utils.Svg exposing (..)


alive : Svg msg
alive =
    Svg.svg
        [ width_ 96
        , height_ 180
        , viewBox_ 0 0 80 150
        ]
        [ Svg.g [ fill "none", fillRule "evenodd" ]
            [ Svg.path [ fill_ trunkColor, d "M28.3 78.4h6.2v35.5h-6.2z" ] []
            , Svg.path [ fill_ trunkColor, d "M9.6 61.2l3.4-3.5 21.3 20.6-3.4 3.5z" ] []
            , Svg.path [ fill_ trunkColor, d "M67.3 47.3L64 44 28 78.5l3.4 3.4z" ] []
            , Svg.path [ fill_ trunkColor, d "M15.6 24.6l3.5-3.6 35.8 34.6-3.4 3.6z" ] []
            , Svg.path [ d "M65 25v25h-.5a12.5 12.5 0 1 1 .5-25z", fill_ leftColor ] []
            , Svg.path [ d "M64 25v25h.5a12.5 12.5 0 1 0-.5-25z", fill_ rightColor ] []
            , Svg.path [ d "M19 0v25h-.5A12.5 12.5 0 1 1 19 0z", fill_ leftColor ] []
            , Svg.path [ d "M18 0v25h.5A12.5 12.5 0 1 0 18 0z", fill_ rightColor ] []
            , Svg.path [ d "M13 38v25h-.5a12.5 12.5 0 1 1 .5-25z", fill_ leftColor ] []
            , Svg.path [ d "M12 38v25h.5a12.5 12.5 0 1 0-.5-25z", fill_ rightColor ] []
            ]
        ]


trunkColor : Color
trunkColor =
    Palette.brown


leftColor : Color
leftColor =
    Palette.green7


rightColor : Color
rightColor =
    Palette.green9
