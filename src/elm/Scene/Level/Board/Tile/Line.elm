module Scene.Level.Board.Tile.Line exposing
    ( Model
    , ViewModel
    , view
    )

import Element exposing (Color)
import Game.Board.Move as Move exposing (Move)
import Game.Board.Tile as Tile exposing (State(..), Tile(..))
import Html exposing (Html, div)
import Scene.Level.Board.Tile.Position as Position
import Scene.Level.Board.Tile.Scale as Scale
import Scene.Level.Board.Tile.Stroke as Stroke
import Seed exposing (Seed)
import Utils.Html as Html
import Utils.Style as Style
import Utils.Transform as Transform
import Utils.Transition as Transition
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
    { width = round (50 * Scale.factor model.window)
    , height = round (Stroke.thickness model.window)
    , offsetX = offsetX model direction
    , offsetY = offsetY model direction
    , rotate = .rotate (offsets direction)
    , color = toColor model tile_
    }


type alias Offsets =
    { x : Float
    , y : Float
    , rotate : Float
    }


offsetX : Model -> Direction -> Float
offsetX model direction =
    Position.x model + .x (offsets direction) * Scale.factor model.window


offsetY : Model -> Direction -> Float
offsetY model direction =
    Position.y model + .y (offsets direction) * Scale.factor model.window


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
        , Transition.background_ 300 []
        , Style.absolute
        , Style.transform
            [ Transform.translate model.offsetX model.offsetY
            , Transform.rotate model.rotate
            ]
        ]
        []
