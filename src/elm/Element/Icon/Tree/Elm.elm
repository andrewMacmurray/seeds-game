module Element.Icon.Tree.Elm exposing
    ( Colors
    , alive
    , dead
    , tree
    )

import Element exposing (Color)
import Element.Palette as Palette
import Simple.Transition as Transition
import Svg exposing (Svg)
import Svg.Attributes exposing (..)
import Utils.Svg exposing (..)
import Utils.Transition as Transition



-- Elm Tree


type alias Options =
    { colors : Colors
    , delay : Transition.Millis
    }


type alias Colors =
    { left : Color
    , right : Color
    }



-- Colors


alive : Colors
alive =
    { left = Palette.green4
    , right = Palette.green9
    }


dead : Colors
dead =
    { left = Palette.brown8
    , right = Palette.brown9
    }



-- View


scale : Float
scale =
    0.13


tree : Options -> Svg msg
tree { colors, delay } =
    let
        transition_ ms =
            transition (delay + ms)
    in
    Svg.svg
        [ width_ (vw * scale)
        , height_ (vh * scale)
        , viewBox_ 0 0 vw vh
        ]
        [ Svg.path [ fill_ trunkColor, d "M28.3 78.4h6.2v35.5h-6.2z" ] []
        , Svg.path [ fill_ trunkColor, d "M9.6 61.2l3.4-3.5 21.3 20.6-3.4 3.5z" ] []
        , Svg.path [ fill_ trunkColor, d "M67.3 47.3L64 44 28 78.5l3.4 3.4z" ] []
        , Svg.path [ fill_ trunkColor, d "M15.6 24.6l3.5-3.6 35.8 34.6-3.4 3.6z" ] []
        , Svg.path [ transition_ 50, d "M65 25v25h-.5a12.5 12.5 0 1 1 .5-25z", fill_ colors.left ] []
        , Svg.path [ transition_ 50, d "M64 25v25h.5a12.5 12.5 0 1 0-.5-25z", fill_ colors.right ] []
        , Svg.path [ transition_ 100, d "M19 0v25h-.5A12.5 12.5 0 1 1 19 0z", fill_ colors.left ] []
        , Svg.path [ transition_ 100, d "M18 0v25h.5A12.5 12.5 0 1 0 18 0z", fill_ colors.right ] []
        , Svg.path [ transition_ 150, d "M13 38v25h-.5a12.5 12.5 0 1 1 .5-25z", fill_ colors.left ] []
        , Svg.path [ transition_ 150, d "M12 38v25h.5a12.5 12.5 0 1 0-.5-25z", fill_ colors.right ] []
        ]


transition : Transition.Millis -> Svg.Attribute msg
transition ms =
    Transition.fill_ ms []



-- Config


vw : number
vw =
    80


vh : number
vh =
    150


trunkColor : Color
trunkColor =
    Palette.brown3
