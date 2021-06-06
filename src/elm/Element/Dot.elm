module Element.Dot exposing
    ( el
    , html
    , solid
    , split
    , split_
    )

import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Html
import Utils.Background as Background
import Utils.Html.Style as Style



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


html attrs options =
    Html.div
        (List.append
            [ Style.width options.size
            , Style.height options.size
            , Style.rounded options.size
            , Style.background options.color
            ]
            attrs
        )
        []



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


split_ options =
    Html.div
        [ Style.width options.size
        , Style.height options.size
        , Style.rounded options.size
        , Style.splitBackground ( options.left, options.right )
        ]
        []



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
