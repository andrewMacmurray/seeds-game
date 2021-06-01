module Scene.Level.Board.Tile.Leaving2 exposing (Model, attributes)

import Board
import Board.Block as Block exposing (Block)
import Board.Move as Move exposing (Move)
import Board.Scores as Scores
import Board.Tile as Tile exposing (State(..), Tile(..))
import Dict
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
    , tileSettings : List Tile.Setting
    }



-- Leaving Styles


attributes : Model -> Move -> List (Attribute msg)
attributes model move =
    let
        block =
            Move.block move
    in
    if Block.isLeaving block && not (Block.isBurst block) then
        --List.append (handleExitDirection move model)
        [ transition block
        , alpha 0.2
        ]

    else
        []


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


handleExitDirection : Move -> Model -> List (Attribute msg)
handleExitDirection move model =
    case Move.tileState move of
        Leaving Rain _ ->
            getLeavingStyle Rain model

        Leaving Sun _ ->
            getLeavingStyle Sun model

        Leaving (Seed seedType) _ ->
            getLeavingStyle (Seed seedType) model

        _ ->
            []


getLeavingStyle : Tile -> Model -> List (Attribute msg)
getLeavingStyle tileType model =
    newLeavingStyles model
        |> Dict.get (Tile.hash tileType)
        |> Maybe.withDefault []


newLeavingStyles : Model -> Dict.Dict String (List (Attribute msg))
newLeavingStyles model =
    model.tileSettings
        |> Scores.tileTypes
        |> List.indexedMap (prepareLeavingStyle model)
        |> Dict.fromList


prepareLeavingStyle : Model -> Int -> Tile -> ( String, List (Attribute msg) )
prepareLeavingStyle model resourceBankIndex tileType =
    ( Tile.hash tileType
    , [ moveRight (exitXDistance resourceBankIndex model)
      , moveUp (exitYDistance model)
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
