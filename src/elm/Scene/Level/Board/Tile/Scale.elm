module Scene.Level.Board.Tile.Scale exposing
    ( height
    , width
    )

import Window exposing (Window)



-- Tile Scale


width : Window -> Int
width window =
    round (baseX * scale window)


height : Window -> Int
height window =
    round (baseY * scale window)


scale : Window -> Float
scale window =
    case Window.size window of
        Window.Small ->
            0.8

        Window.Medium ->
            0.98

        Window.Large ->
            1.2


baseX : number
baseX =
    55


baseY : number
baseY =
    51
