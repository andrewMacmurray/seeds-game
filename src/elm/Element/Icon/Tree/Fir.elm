module Element.Icon.Tree.Fir exposing
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
import Utils.Svg as Svg exposing (..)
import Utils.Transition as Transition



-- Fir Tree


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
    { left = Palette.green8
    , right = Palette.green10
    }


dead : Colors
dead =
    { left = Palette.brown8
    , right = Palette.brown9
    }



-- View


scale : Float
scale =
    0.1


tree : Options -> Svg msg
tree options =
    Svg.svg
        [ viewBox_ 0 0 vw vh
        , Svg.width_ (vw * scale)
        , Svg.height_ (vh * scale)
        ]
        [ Svg.path [ fill_ trunkColor, d "M12.2 41h6.6V75h-6.6z" ] []
        , Svg.path
            [ d "M15.6.3s14.8 20.4 14.8 32.9c0 8.2-6.6 14.8-14.8 14.8V.4z"
            , fill_ options.colors.left
            , Transition.fill_ 500 [ Transition.delay options.delay ]
            ]
            []
        , Svg.path
            [ d "M.8 33.2C.8 21 14.7 1.6 15.5.4V48C7.4 48 .8 41.4.8 33.2z"
            , fill_ options.colors.right
            , Transition.fill_ 500 [ Transition.delay (options.delay + 200) ]
            ]
            []
        ]



-- Constants


vw : number
vw =
    40


vh : number
vh =
    100


trunkColor : Color
trunkColor =
    Palette.brown3
