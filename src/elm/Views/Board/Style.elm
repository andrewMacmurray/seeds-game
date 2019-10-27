module Views.Board.Style exposing
    ( ViewModel
    , fullWidth
    , height
    , marginTop
    , offsetBottom
    , offsetLeft
    , offsetTop
    , scoreIconSize
    , topBarHeight
    , width
    )

import Board
import Board.Tile as Tile exposing (Tile)
import Css.Style as Style exposing (..)
import Views.Board.Tile.Style as Tile
import Window exposing (Window)



-- Score Bar


scoreIconSize : number
scoreIconSize =
    32


topBarHeight : number
topBarHeight =
    80



-- Board


type alias ViewModel =
    { window : Window
    , boardSize : Board.Size
    }


marginTop : ViewModel -> Style
marginTop model =
    Style.marginTop <| toFloat <| offsetTop model


offsetTop : ViewModel -> Int
offsetTop ({ window } as model) =
    (window.height - height model) // 2 + (topBarHeight // 2) - 10


offsetBottom : ViewModel -> Int
offsetBottom ({ window } as model) =
    window.height - offsetTop model - height model


offsetLeft : ViewModel -> Int
offsetLeft ({ window } as model) =
    (window.width - width model) // 2


height : ViewModel -> Int
height { window, boardSize } =
    round (Tile.baseSizeY * Tile.scale window) * boardSize.y


width : ViewModel -> Int
width { window, boardSize } =
    Tile.width window * boardSize.x


fullWidth : Window -> Int
fullWidth window =
    Tile.width window * 8