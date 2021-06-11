module Scene.Level.Board.Tile.Line exposing
    ( Model
    , ViewModel
    , view
    )

import Board.Move as Move exposing (Move)
import Board.Tile as Tile exposing (State(..), Tile(..))
import Css.Transform as Transform exposing (Transform)
import Element exposing (Color)
import Html exposing (Html, div)
import Scene.Level.Board.Tile.Position as Position
import Scene.Level.Board.Tile.Stroke as Stroke
import Seed exposing (Seed)
import Utils.Html as Html
import Utils.Html.Style as Style
import Window exposing (Window)



-- Model


type alias Model =
    { activeSeed : Maybe Seed
    , window : Window
    , move : Move
    }


type alias ViewModel =
    { offsetX : Float
    , offsetY : Float
    , width : Int
    , height : Int
    , rotate : Float
    , color : Color
    }


type Direction
    = Up
    | Down
    | Left
    | Right



-- To Line


toLine : Model -> Maybe ViewModel
toLine model =
    case Move.tileState model.move of
        Tile.Dragging tile_ _ Tile.Left ->
            Just (toLine_ model tile_ Left)

        Tile.Dragging tile_ _ Tile.Right ->
            Just (toLine_ model tile_ Right)

        Tile.Dragging tile_ _ Tile.Up ->
            Just (toLine_ model tile_ Up)

        Tile.Dragging tile_ _ Tile.Down ->
            Just (toLine_ model tile_ Down)

        _ ->
            Nothing


toLine_ : Model -> Tile -> Direction -> ViewModel
toLine_ model tile_ direction =
    let
        scale =
            Tile.scale model.window
    in
    { width = round (50 * scale)
    , height = round (5 * scale)
    , offsetX = Position.x model + .x (offsets direction) * scale
    , offsetY = Position.y model + .y (offsets direction) * scale
    , rotate = .rotate (offsets direction)
    , color = toColor model tile_
    }


type alias Offsets =
    { x : Float
    , y : Float
    , rotate : Float
    }


offsets : Direction -> Offsets
offsets direction =
    case direction of
        Up ->
            { x = 3
            , y = 0
            , rotate = 90
            }

        Down ->
            { x = 3
            , y = 50
            , rotate = 90
            }

        Left ->
            { x = -25
            , y = 22
            , rotate = 0
            }

        Right ->
            { x = 26
            , y = 23
            , rotate = 0
            }


toColor : Model -> Tile -> Color
toColor model tile_ =
    case model.activeSeed of
        Just seed ->
            Stroke.darker (Seed seed)

        Nothing ->
            Stroke.darker tile_



-- View


view : Model -> Html msg
view =
    toLine >> Html.showIfJust view_


view_ : ViewModel -> Html msg
view_ model =
    div
        [ Style.width model.width
        , Style.height model.height
        , Style.background model.color
        , Style.absolute
        , Style.transform
            [ Transform.translate model.offsetX model.offsetY
            , Transform.rotate model.rotate
            ]
        ]
        []
