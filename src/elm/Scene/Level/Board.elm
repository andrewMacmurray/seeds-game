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

import Board
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
offsetTop ({ window } as model) =
    (window.height - height model) // 2 + (topBarHeight // 2) - 10


offsetBottom : Model model -> Int
offsetBottom ({ window } as model) =
    window.height - offsetTop model - height model


offsetLeft : Model model -> Int
offsetLeft ({ window } as model) =
    (window.width - width model) // 2


height : Model model -> Int
height { window, boardSize } =
    Scale.outerHeight window * boardSize.y


width : Model model -> Int
width { window, boardSize } =
    Scale.outerWidth window * boardSize.x


fullWidth : Window -> Int
fullWidth window =
    Scale.outerWidth window * 8
