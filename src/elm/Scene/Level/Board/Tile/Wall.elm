module Scene.Level.Board.Tile.Wall exposing (view, view_)

import Board.Block as Block
import Board.Move as Move exposing (Move)
import Board.Tile as Tile
import Element exposing (..)
import Element.Background as Background
import Utils.Element as Element
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


view_ : { a | window : Window } -> Color -> Element msg
view_ model color =
    Element.square (wallSize model) [ Background.color color ] none


wallSize : { a | window : Window } -> Int
wallSize model =
    round (Tile.scale model.window * 45)
