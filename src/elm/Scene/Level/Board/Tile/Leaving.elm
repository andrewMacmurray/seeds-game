module Scene.Level.Board.Tile.Leaving exposing
    ( Model
    , Offsets
    , offsets
    )

import Board
import Board.Move as Move exposing (Move)
import Board.Scores as Scores
import Board.Tile as Tile exposing (State(..), Tile(..))
import Dict exposing (Dict)
import Level.Setting.Tile as Tile
import Scene.Level.Board.Style as Board
import Scene.Level.Board.Tile.Scale as Scale
import Window exposing (Window)



-- Model


type alias Model =
    { window : Window
    , boardSize : Board.Size
    , settings : List Tile.Setting
    , move : Move
    }


type alias Offsets =
    { x : Float
    , y : Float
    }



-- Offsets


offsets : Model -> Maybe Offsets
offsets model =
    case Move.tileState model.move of
        Leaving Rain _ ->
            offsetsFor Rain model

        Leaving Sun _ ->
            offsetsFor Sun model

        Leaving (Seed seedType) _ ->
            offsetsFor (Seed seedType) model

        _ ->
            Nothing


offsetsFor : Tile -> Model -> Maybe Offsets
offsetsFor tile =
    allOffsets >> Dict.get (Tile.toString tile)


allOffsets : Model -> Dict String Offsets
allOffsets model =
    model.settings
        |> Scores.tileTypes
        |> List.indexedMap (toOffsets model)
        |> Dict.fromList


toOffsets : Model -> Int -> Tile -> ( String, Offsets )
toOffsets model resourceBankIndex tile_ =
    ( Tile.toString tile_
    , { x = offsetXDistance resourceBankIndex model
      , y = -(offsetYDistance model)
      }
    )


offsetXDistance : Int -> Model -> Float
offsetXDistance resourceBankIndex model =
    let
        scoreWidth =
            Board.scoreIconSize * 2

        scoreBarWidth =
            model.settings
                |> List.filter Scores.collectible
                |> List.length
                |> (*) scoreWidth

        baseOffset =
            (Board.width model - scoreBarWidth) // 2

        offset =
            exitOffset (Scale.factor model.window)
    in
    toFloat (baseOffset + resourceBankIndex * scoreWidth) + offset


exitOffset : Float -> Float
exitOffset x =
    25 * (x ^ 2) - (75 * x) + Scale.baseX


offsetYDistance : Model -> Float
offsetYDistance model =
    toFloat (Board.offsetTop model) - 9
