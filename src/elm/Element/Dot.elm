module Element.Dot exposing (el, solid)

import Element exposing (..)
import Element.Background as Background
import Element.Border as Border


type alias Solid =
    { size : Int
    , color : Color
    }


solid : Solid -> Element msg
solid options =
    Element.el
        [ Background.color options.color
        , width (px options.size)
        , height (px options.size)
        , Border.rounded options.size
        ]
        none


type alias El =
    { size : Int
    , color : Color
    }


el : El -> Element msg -> Element msg
el options el_ =
    Element.el
        [ Background.color options.color
        , width (px options.size)
        , height (px options.size)
        , Border.rounded options.size
        ]
        (Element.el [ centerX, centerY ] el_)
