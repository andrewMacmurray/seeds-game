module Element.Icon.Tree.Pine exposing (alive)

import Element exposing (Color)
import Element.Palette as Palette
import Svg exposing (Svg)
import Svg.Attributes exposing (..)
import Utils.Svg exposing (..)



-- Pine


scale : Float
scale =
    1.4


alive : Svg msg
alive =
    Svg.svg
        [ width_ (vw * scale)
        , height_ (vh * scale)
        , viewBox_ 0 0 vw vh
        ]
        [ Svg.path [ fill_ trunkColor, d "M34.1 51.8h6.8v36.7h-6.8z" ] []
        , Svg.path [ fill_ trunkColor, d "M12.7 33.2l4.8-4.8L41 52l-4.8 4.8z" ] []
        , Svg.path [ fill_ trunkColor, d "M62.5 33.2l-4.9-4.8L34 52l4.8 4.8z" ] []
        , Svg.path [ d "M10.4 4.7s9.7 13.4 9.7 21.6c0 5.4-4.3 9.7-9.7 9.7V4.7z", fill_ leftColor ] []
        , Svg.path [ d "M.7 26.3c0-8 9.1-20.8 9.7-21.6V36a9.7 9.7 0 0 1-9.7-9.7z", fill_ rightColor ] []
        , Svg.path [ d "M37.5 18s9.7 13.5 9.7 21.7c0 5.4-4.3 9.7-9.7 9.7V18.1z", fill_ leftColor ] []
        , Svg.path [ d "M27.8 39.7c0-8 9.1-20.8 9.7-21.6v31.3a9.7 9.7 0 0 1-9.7-9.7z", fill_ rightColor ] []
        , Svg.path [ d "M37.5 0s9.7 13.4 9.7 21.6c0 5.4-4.3 9.8-9.7 9.8V0z", fill_ leftColor ] []
        , Svg.path [ d "M27.8 21.6c0-8 9.1-20.7 9.7-21.5v31.3a9.7 9.7 0 0 1-9.7-9.8z", fill_ rightColor ] []
        , Svg.path [ d "M51.3 11.9S61 25.3 61 33.5c0 5.4-4.3 9.7-9.7 9.7V12z", fill_ leftColor ] []
        , Svg.path [ d "M41.7 33.5c0-8 9-20.8 9.6-21.6v31.3a9.7 9.7 0 0 1-9.6-9.7z", fill_ rightColor ] []
        , Svg.path [ d "M22.7 11.9s9.7 13.4 9.7 21.6c0 5.4-4.4 9.7-9.7 9.7V12z", fill_ leftColor ] []
        , Svg.path [ d "M13 33.5c0-8 9.1-20.8 9.7-21.6v31.3a9.7 9.7 0 0 1-9.7-9.7z", fill_ rightColor ] []
        , Svg.path [ d "M64.6 4.7s9.7 13.4 9.7 21.6c0 5.4-4.3 9.7-9.7 9.7V4.7z", fill_ leftColor ] []
        , Svg.path [ d "M55 26.3c0-8 9-20.8 9.6-21.6V36a9.7 9.7 0 0 1-9.6-9.7z", fill_ rightColor ] []
        ]



-- Config


vw : number
vw =
    80


vh : number
vh =
    100


leftColor : Color
leftColor =
    Palette.green7


rightColor : Color
rightColor =
    Palette.green9


trunkColor : Color
trunkColor =
    Palette.chocolate
