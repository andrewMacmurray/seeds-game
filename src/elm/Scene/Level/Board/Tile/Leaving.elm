module Scene.Level.Board.Tile.Leaving exposing
    ( Model
    , apply
    )

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
                , transitionDelay = delay (Move.block model.move)
                , scale = 0.5
                , alpha = 0.2
            }

    else if Block.isLeaving (Move.block model.move) then
        { tileModel
            | transition = 800
            , scale = 8
            , alpha = 0
        }

    else
        tileModel


isLeaving : Block -> Bool
isLeaving block =
    Block.isLeaving block && not (Block.isBurst block)


delay : Block -> Int
delay block =
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
    exitOffsets model
        |> Dict.get (Tile.toString tile_)
        |> Maybe.map (applyOffsets tileModel)
        |> Maybe.withDefault tileModel


applyOffsets : TileModel model -> Offsets -> TileModel model
applyOffsets tileModel offsets =
    { tileModel
        | offsetX = offsets.x
        , offsetY = offsets.y
    }


exitOffsets : Model -> Dict String Offsets
exitOffsets model =
    model.settings
        |> Scores.tileTypes
        |> List.indexedMap (toOffsets model)
        |> Dict.fromList


type alias Offsets =
    { x : Float
    , y : Float
    }


toOffsets : Model -> Int -> Tile -> ( String, Offsets )
toOffsets model resourceBankIndex tile_ =
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
