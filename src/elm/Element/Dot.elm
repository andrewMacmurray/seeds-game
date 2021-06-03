module Element.Dot exposing
    ( el
    , solid
    , split
    )

import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Utils.Background as Background



-- Solid


type alias Solid =
    { size : Int
    , color : Color
    }


solid : Solid -> Element msg
solid options =
    dot_
        { background = Background.color options.color
        , size = options.size
        , el = none
        }



-- Split


type alias Split =
    { left : Color
    , right : Color
    , size : Int
    }


split : Split -> Element msg
split options =
    dot_
        { background = Background.split ( options.left, options.right )
        , size = options.size
        , el = none
        }



-- Element


type alias El =
    { size : Int
    , color : Color
    }


el : El -> Element msg -> Element msg
el options el_ =
    dot_
        { background = Background.color options.color
        , size = options.size
        , el = Element.el [ centerX, centerY ] el_
        }



-- Internal


type alias Dot_ msg =
    { background : Attribute msg
    , size : Int
    , el : Element msg
    }


dot_ : Dot_ msg -> Element msg
dot_ options =
    Element.el
        [ options.background
        , width (px options.size)
        , height (px options.size)
        , Border.rounded options.size
        ]
        options.el
