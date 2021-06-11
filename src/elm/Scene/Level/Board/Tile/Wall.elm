module Scene.Level.Board.Tile.Wall exposing
    ( html
    , view
    , view_
    )

import Board.Block as Block
import Board.Move as Move exposing (Move)
import Element exposing (..)
import Element.Background as Background
import Html exposing (Html)
import Scene.Level.Board.Tile.Scale as Scale
import Utils.Element as Element
import Utils.Html as Html
import Utils.Html.Style as Style
import Window exposing (Window)



-- Model


type alias Model =
    { window : Window
    , move : Move
    }



-- View


view : Model -> Element msg
view model =
    case Move.block model.move of
        Block.Wall color ->
            view_ model color

        _ ->
            none


html : { a | window : Window } -> Color -> Html msg
html model color =
    Html.square (wallSize model) [ Style.background color ] []


view_ : { a | window : Window } -> Color -> Element msg
view_ model color =
    Element.square (wallSize model) [ Background.color color ] none


wallSize : { a | window : Window } -> Int
wallSize model =
    round (Scale.factor model.window * 45)
