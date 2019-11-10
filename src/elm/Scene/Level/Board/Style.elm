module Scene.Level.Board.Style exposing
    ( ViewModel
    , fullWidth
    , height
    , leaving
    , marginTop
    , offsetBottom
    , offsetLeft
    , offsetTop
    , scoreIconSize
    , topBarHeight
    , width
    )

import Board
import Board.Block as Block
import Board.Move as Move exposing (Move)
import Board.Scores as Scores
import Board.Tile as Tile exposing (State(..), Tile(..))
import Css.Style as Style exposing (..)
import Css.Transform exposing (scale, translate)
import Css.Transition exposing (delay, transitionAll)
import Dict
import Level.Setting.Tile as Tile
import Scene.Level.Board.Tile.Style as Tile
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
    , tileSettings : List Tile.Setting
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



-- Leaving Styles


leaving : ViewModel -> Move -> List Style
leaving model move =
    let
        block =
            Move.block move
    in
    if Block.isLeaving block && not (Block.isBurst block) then
        [ transitionAll 800 [ delay <| modBy 5 (Block.leavingOrder block) * 80 ]
        , opacity 0.2
        , handleExitDirection move model
        ]

    else
        []


handleExitDirection : Move -> ViewModel -> Style
handleExitDirection move model =
    case Block.tileState <| Move.block move of
        Leaving Rain _ ->
            getLeavingStyle Rain model

        Leaving Sun _ ->
            getLeavingStyle Sun model

        Leaving (Seed seedType) _ ->
            getLeavingStyle (Seed seedType) model

        _ ->
            Style.none


getLeavingStyle : Tile -> ViewModel -> Style
getLeavingStyle tileType model =
    newLeavingStyles model
        |> Dict.get (Tile.hash tileType)
        |> Maybe.withDefault Style.none


newLeavingStyles : ViewModel -> Dict.Dict String Style
newLeavingStyles model =
    model.tileSettings
        |> Scores.tileTypes
        |> List.indexedMap (prepareLeavingStyle model)
        |> Dict.fromList


prepareLeavingStyle : ViewModel -> Int -> Tile -> ( String, Style )
prepareLeavingStyle model resourceBankIndex tileType =
    ( Tile.hash tileType
    , transform
        [ translate (exitXDistance resourceBankIndex model) -(exitYDistance model)
        , scale 0.5
        ]
    )


exitXDistance : Int -> ViewModel -> Float
exitXDistance resourceBankIndex model =
    let
        scoreWidth =
            scoreIconSize * 2

        scoreBarWidth =
            model.tileSettings
                |> List.filter Scores.collectible
                |> List.length
                |> (*) scoreWidth

        baseOffset =
            (width model - scoreBarWidth) // 2

        offset =
            exitOffset <| Tile.scale model.window
    in
    toFloat (baseOffset + resourceBankIndex * scoreWidth) + offset


exitOffset : Float -> Float
exitOffset x =
    25 * (x ^ 2) - (75 * x) + Tile.baseSizeX


exitYDistance : ViewModel -> Float
exitYDistance model =
    toFloat (offsetTop model) - 9
