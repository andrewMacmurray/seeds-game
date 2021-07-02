module Element.Dot exposing
    ( el
    , html
    , solid
    , split_
    )

import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Html exposing (Html)
import Utils.Style as Style



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


html : List (Html.Attribute msg) -> Solid -> Html msg
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


split_ : List (Html.Attribute msg) -> Split -> Html msg
split_ attrs options =
    Html.div
        (List.append
            [ Style.width options.size
            , Style.height options.size
            , Style.rounded options.size
            , Style.splitBackground
                { left = options.left
                , right = options.right
                }
            ]
            attrs
        )
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
