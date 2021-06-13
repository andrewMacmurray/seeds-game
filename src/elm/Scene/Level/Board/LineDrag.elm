module Scene.Level.Board.LineDrag exposing
    ( Model
    , view
    )

import Element exposing (Color, Element)
import Element.Palette as Palette
import Element.Touch as Touch
import Game.Board as Board exposing (Board)
import Game.Board.Move as Move exposing (Move)
import Scene.Level.Board as Board
import Scene.Level.Board.Tile.Scale as Scale
import Scene.Level.Board.Tile.Stroke as Stroke
import Svg exposing (Svg)
import Svg.Attributes exposing (..)
import Utils.Element as Element
import Utils.Svg as Svg
import Window exposing (Window)



-- Line Drag


type alias Model =
    { window : Window
    , boardSize : Board.Size
    , board : Board
    , isDragging : Bool
    , point : Touch.Point
    }


type alias ViewModel =
    { window : Window
    , y1 : Float
    , x1 : Float
    , y2 : Int
    , x2 : Int
    , thickness : Float
    , color : Color
    }


toViewModel : Model -> ViewModel
toViewModel model =
    { window = model.window
    , color = strokeColor model
    , thickness = Stroke.thickness model.window
    , x1 = .x (lastMoveOrigin model)
    , y1 = .y (lastMoveOrigin model)
    , x2 = model.point.x
    , y2 = model.point.y
    }


strokeColor : Model -> Color
strokeColor model =
    Board.activeMoveType model.board
        |> Maybe.map Stroke.darker
        |> Maybe.withDefault Palette.greyYellow


lastMoveOrigin : Model -> { x : Float, y : Float }
lastMoveOrigin model =
    { x = lastX model + offsetX model - (tileWidth model / 2) + 1
    , y = lastY model + offsetY model - (tileHeight model / 2)
    }


lastY : Model -> Float
lastY model =
    toFloat (Move.y (lastMove model) + 1) * tileHeight model


lastX : Model -> Float
lastX model =
    toFloat (Move.x (lastMove model) + 1) * tileWidth model


lastMove : Model -> Move
lastMove =
    .board >> Board.lastMove


offsetY : Model -> Float
offsetY =
    Board.offsetTop >> toFloat


offsetX : Model -> Float
offsetX model =
    toFloat ((model.window.width - Board.width model) // 2)


tileHeight : Model -> Float
tileHeight =
    .window
        >> Scale.outerHeight
        >> toFloat


tileWidth : Model -> Float
tileWidth =
    .window
        >> Scale.outerWidth
        >> toFloat



-- View


view : Model -> Element msg
view model =
    toViewModel model
        |> view_
        |> wrapper model.isDragging


wrapper : Bool -> Svg msg -> Element msg
wrapper isVisible el_ =
    Element.el
        [ Element.disableTouch
        , Element.visibleIf isVisible
        ]
        (Element.html el_)


view_ : ViewModel -> Svg msg
view_ model =
    Svg.window model.window
        [ Svg.disableTouch ]
        [ Svg.line
            [ Svg.strokeWidth_ model.thickness
            , Svg.stroke_ model.color
            , strokeLinecap "round"
            , x1 (String.fromFloat model.x1)
            , y1 (String.fromFloat model.y1)
            , x2 (String.fromInt model.x2)
            , y2 (String.fromInt model.y2)
            ]
            []
        ]
