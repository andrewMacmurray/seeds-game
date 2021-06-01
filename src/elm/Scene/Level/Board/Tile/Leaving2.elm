module Scene.Level.Board.Tile.Leaving2 exposing (Model, attributes)

import Board
import Board.Block as Block exposing (Block)
import Board.Move as Move exposing (Move)
import Board.Scores as Scores
import Board.Tile as Tile exposing (State(..), Tile(..))
import Dict exposing (Dict)
import Element exposing (..)
import Element.Transition as Transition
import Level.Setting.Tile as Tile
import Scene.Level.Board.Style as Board
import Simple.Transition as Transition
import Window exposing (Window)



-- Model


type alias Model =
    { window : Window
    , boardSize : Board.Size
    , settings : List Tile.Setting
    , move : Move
    }



-- Leaving Styles


attributes : Model -> List (Attribute msg) -> List (Attribute msg)
attributes model defaults =
    let
        block =
            Move.block model.move
    in
    if Block.isLeaving block && not (Block.isBurst block) then
        List.append (handleExitDirection model)
            [ transition block
            , alpha 0.2
            ]

    else
        defaults


transition : Block -> Attribute msg
transition block =
    Transition.all_
        { duration = 800
        , options = [ transitionDelay block ]
        }
        [ Transition.transform
        , Transition.opacity
        ]


transitionDelay : Block -> Transition.Option
transitionDelay block =
    Transition.delay (modBy 5 (Block.leavingOrder block) * 80)


handleExitDirection : Model -> List (Attribute msg)
handleExitDirection model =
    case Move.tileState model.move of
        Leaving Rain _ ->
            leavingAttributes Rain model

        Leaving Sun _ ->
            leavingAttributes Sun model

        Leaving (Seed seedType) _ ->
            leavingAttributes (Seed seedType) model

        _ ->
            []


leavingAttributes : Tile -> Model -> List (Attribute msg)
leavingAttributes tileType model =
    leavingAttributes_ model
        |> Dict.get (Tile.hash tileType)
        |> Maybe.withDefault []


leavingAttributes_ : Model -> Dict String (List (Attribute msg))
leavingAttributes_ model =
    model.settings
        |> Scores.tileTypes
        |> List.indexedMap (prepareLeavingStyle model)
        |> Dict.fromList


prepareLeavingStyle : Model -> Int -> Tile -> ( String, List (Attribute msg) )
prepareLeavingStyle model resourceBankIndex tileType =
    ( Tile.hash tileType
    , [ moveRight (exitXDistance resourceBankIndex model)
      , moveDown -(exitYDistance model)
      , scale 0.5
      ]
    )


exitXDistance : Int -> Model -> Float
exitXDistance resourceBankIndex model =
    let
        scoreWidth =
            Board.scoreIconSize * 2

        scoreBarWidth =
            model.settings
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
