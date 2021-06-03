module Scene.Level.Board.Tile.Leaving2 exposing (Model, apply)

import Board
import Board.Block as Block exposing (Block)
import Board.Move as Move exposing (Move)
import Board.Scores as Scores
import Board.Tile as Tile exposing (State(..), Tile(..))
import Dict exposing (Dict)
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


type alias TileModel model =
    { model
        | transition : Transition.Millis
        , transitionDelay : Transition.Millis
        , offsetX : Float
        , offsetY : Float
        , scale : Float
        , alpha : Float
    }


apply : Model -> TileModel model -> TileModel model
apply model tileModel =
    if isLeaving (Move.block model.move) then
        withExitOffsets model
            { tileModel
                | transition = 800
                , transitionDelay = transitionDelay (Move.block model.move)
                , scale = 0.5
                , alpha = 0.2
            }

    else
        tileModel



-- Leaving Styles


isLeaving : Block -> Bool
isLeaving block =
    Block.isLeaving block && not (Block.isBurst block)


transitionDelay : Block -> Int
transitionDelay block =
    modBy 5 (Block.leavingOrder block) * 80


withExitOffsets : Model -> TileModel model -> TileModel model
withExitOffsets model tileModel =
    case Move.tileState model.move of
        Leaving Rain _ ->
            exitOffsetsFor Rain model tileModel

        Leaving Sun _ ->
            exitOffsetsFor Sun model tileModel

        Leaving (Seed seedType) _ ->
            exitOffsetsFor (Seed seedType) model tileModel

        _ ->
            tileModel


exitOffsetsFor : Tile -> Model -> TileModel model -> TileModel model
exitOffsetsFor tile_ model tileModel =
    leavingAttributes_ model
        |> Dict.get (Tile.toString tile_)
        |> Maybe.map (\offsets -> { tileModel | offsetX = offsets.x, offsetY = offsets.y })
        |> Maybe.withDefault tileModel


leavingAttributes_ : Model -> Dict String { x : Float, y : Float }
leavingAttributes_ model =
    model.settings
        |> Scores.tileTypes
        |> List.indexedMap (toLeavingAttributes model)
        |> Dict.fromList


toLeavingAttributes : Model -> Int -> Tile -> ( String, { x : Float, y : Float } )
toLeavingAttributes model resourceBankIndex tile_ =
    ( Tile.toString tile_
    , { x = exitXDistance resourceBankIndex model
      , y = -(exitYDistance model)
      }
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
