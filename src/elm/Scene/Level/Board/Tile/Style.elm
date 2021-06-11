module Scene.Level.Board.Tile.Style exposing
    ( height
    , position
    , width
    )

import Board.Coord as Coord exposing (Coord)
import Scene.Level.Board.Tile.Scale as Scale
import Window exposing (Window)



-- Tile Position


type alias Position =
    { x : Float
    , y : Float
    }


position : Window -> Coord -> Position
position window coord =
    { x = toFloat <| Coord.x coord * width window
    , y = toFloat <| Coord.y coord * height window
    }


width : Window -> Int
width =
    Scale.outerWidth


height : Window -> Int
height =
    Scale.outerHeight
