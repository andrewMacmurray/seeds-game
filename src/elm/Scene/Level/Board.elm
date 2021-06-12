module Scene.Level.Board exposing
    ( Model
    , fullWidth
    , offsetBottom
    , offsetLeft
    , offsetTop
    , scoreIconSize
    , topBarHeight
    , width
    )

import Game.Board as Board
import Scene.Level.Board.Tile.Scale as Scale
import Window exposing (Window)



-- Score Bar


scoreIconSize : number
scoreIconSize =
    32


topBarHeight : number
topBarHeight =
    80



-- Board


type alias Model model =
    { model
        | window : Window
        , boardSize : Board.Size
    }


offsetTop : Model model -> Int
offsetTop model =
    (model.window.height - height model) // 2 + (topBarHeight // 2) - 10


offsetBottom : Model model -> Int
offsetBottom model =
    model.window.height - offsetTop model - height model


offsetLeft : Model model -> Int
offsetLeft model =
    (model.window.width - width model) // 2


height : Model model -> Int
height model =
    Scale.outerHeight model.window * model.boardSize.y


width : Model model -> Int
width model =
    Scale.outerWidth model.window * model.boardSize.x


fullWidth : Window -> Int
fullWidth window =
    Scale.outerWidth window * 8
