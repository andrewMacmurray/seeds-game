module Element.Icon.Tree.Fir exposing (alive)

import Element.Palette as Palette
import Simple.Transition as Transition
import Svg exposing (Svg)
import Svg.Attributes exposing (..)
import Utils.Svg as Svg exposing (..)
import Utils.Transition as Transition


alive : Svg msg
alive =
    Svg.svg
        [ viewBox_ 0 0 40 100
        , Svg.width_ 40
        , Svg.height_ 100
        ]
        [ Svg.path [ fill_ Palette.darkBrown, d "M12.2 41h6.6V75h-6.6z" ] []
        , Svg.path
            [ Transition.fill_ 500 []
            , d "M15.6.3s14.8 20.4 14.8 32.9c0 8.2-6.6 14.8-14.8 14.8V.4z"
            , fill_ Palette.green7
            ]
            []
        , Svg.path
            [ Transition.fill_ 500 [ Transition.delay 100 ]
            , d "M.8 33.2C.8 21 14.7 1.6 15.5.4V48C7.4 48 .8 41.4.8 33.2z"
            , fill_ Palette.green9
            ]
            []
        ]
