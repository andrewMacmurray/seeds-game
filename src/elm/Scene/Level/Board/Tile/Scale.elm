module Scene.Level.Board.Tile.Scale exposing
    ( baseX
    , factor
    , innerSize
    , outerHeight
    , outerWidth
    )

import Board.Block as Block exposing (Block)
import Board.Move as Move exposing (Move)
import Board.Tile as Tile exposing (Tile)
import Window exposing (Window)



-- Tile Scale


outerWidth : Window -> Int
outerWidth window =
    round (baseX * factor window)


outerHeight : Window -> Int
outerHeight window =
    round (baseY * factor window)


factor : Window -> Float
factor window =
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



-- Size


innerSize : { model | window : Window, move : Move } -> Int
innerSize model =
    round (size_ (Move.block model.move) * factor model.window)


size_ : Block -> Float
size_ =
    Block.foldTile tileSize_ 0


tileSize_ : Tile -> Float
tileSize_ tile =
    case tile of
        Tile.Rain ->
            18

        Tile.Sun ->
            18

        Tile.SeedPod ->
            26

        Tile.Seed _ ->
            22

        Tile.Burst _ ->
            36
