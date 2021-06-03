module Scene.Level.Board.Tile.Leaving exposing (Model, styles)

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
import Scene.Level.Board.Style as Board
import Window exposing (Window)



-- Model


type alias Model =
    { window : Window
    , boardSize : Board.Size
    , tileSettings : List Tile.Setting
    }



-- Leaving Styles


styles : Model -> Move -> List Style
styles model move =
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


handleExitDirection : Move -> Model -> Style
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


getLeavingStyle : Tile -> Model -> Style
getLeavingStyle tileType model =
    newLeavingStyles model
        |> Dict.get (Tile.toString tileType)
        |> Maybe.withDefault Style.none


newLeavingStyles : Model -> Dict.Dict String Style
newLeavingStyles model =
    model.tileSettings
        |> Scores.tileTypes
        |> List.indexedMap (prepareLeavingStyle model)
        |> Dict.fromList


prepareLeavingStyle : Model -> Int -> Tile -> ( String, Style )
prepareLeavingStyle model resourceBankIndex tileType =
    ( Tile.toString tileType
    , transform
        [ translate (exitXDistance resourceBankIndex model) -(exitYDistance model)
        , scale 0.5
        ]
    )


exitXDistance : Int -> Model -> Float
exitXDistance resourceBankIndex model =
    let
        scoreWidth =
            Board.scoreIconSize * 2

        scoreBarWidth =
            model.tileSettings
                |> List.filter Scores.collectible
                |> List.length
                |> (*) scoreWidth

        baseOffset =
            (Board.width (boardViewModel model) - scoreBarWidth) // 2

        offset =
            exitOffset <| Tile.scale model.window
    in
    toFloat (baseOffset + resourceBankIndex * scoreWidth) + offset


exitOffset : Float -> Float
exitOffset x =
    25 * (x ^ 2) - (75 * x) + Tile.baseSizeX


exitYDistance : Model -> Float
exitYDistance model =
    toFloat (Board.offsetTop (boardViewModel model)) - 9



-- View Models


boardViewModel : Model -> Board.ViewModel
boardViewModel model =
    { window = model.window
    , boardSize = model.boardSize
    }
