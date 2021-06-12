module Scene.Level.Board.Tile.Position exposing
    ( fromCoord
    , x
    , y
    )

import Board.Coord as Coord exposing (Coord)
import Board.Move as Move exposing (Move)
import Scene.Level.Board.Tile.Scale as Scale
import Window exposing (Window)



-- Position


type alias Model model =
    { model
        | move : Move
        , window : Window
    }


type alias Position =
    { x : Float
    , y : Float
    }



-- Query


x : Model model -> Float
x =
    position >> .x


y : Model model -> Float
y =
    position >> .y


position : Model model -> Position
position model =
    model.move
        |> Move.coord
        |> fromCoord model.window


fromCoord : Window -> Coord -> Position
fromCoord window coord =
    { x = toFloat (Coord.x coord * Scale.outerWidth window)
    , y = toFloat (Coord.y coord * Scale.outerHeight window)
    }
