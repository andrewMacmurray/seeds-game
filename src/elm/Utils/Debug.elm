module Utils.Debug exposing
    ( goToLevel
    , move
    , progress
    , setProgress
    , tileState
    )

import Board.Move as Move exposing (Move)
import Board.Tile as Tile
import Config.Level as Level exposing (LevelConfig)
import Config.World as World
import Element exposing (..)
import Element.Font as Font
import Level.Progress as Progress exposing (Progress)
import Ports
import Utils.Delay as Delay



-- Progress and Levels


goToLevel : Int -> Int -> (LevelConfig -> msg) -> Cmd msg
goToLevel world level msg =
    Cmd.batch
        [ Delay.trigger (msg (levelConfig world level))
        , setProgress world level
        ]


levelConfig : Int -> Int -> LevelConfig
levelConfig world =
    Level.build_ world >> World.levelConfig


setProgress : Int -> Int -> Cmd msg
setProgress world level =
    Level.build_ world level
        |> Level.toCache
        |> Ports.cacheProgress


progress : Int -> Int -> Progress
progress world level =
    Level.build_ world level
        |> Progress.fromLevel
        |> Progress.setCurrentLevel (Level.build_ world level)



-- Board


move : Move -> Attribute msg
move move_ =
    let
        x =
            Move.x move_ |> String.fromInt

        y =
            Move.y move_ |> String.fromInt
    in
    inFront (el [ centerX, Font.size 12 ] (text ("x" ++ x ++ "y" ++ y)))


tileState : Move -> Attribute msg
tileState move_ =
    inFront (el [ centerX, Font.size 12 ] (text (moveStateText move_)))


moveStateText : Move -> String
moveStateText move_ =
    case Move.tileState move_ of
        Tile.Static tile ->
            "stat"

        Tile.Dragging tile moveOrder bearing ->
            "drag"

        Tile.Leaving tile moveOrder ->
            "leav"

        Tile.Falling tile distance ->
            "fall"

        Tile.Entering tile ->
            "entr"

        Tile.Growing tile moveOrder ->
            "grow"

        Tile.Active tile ->
            "actv"

        Tile.Releasing tile moveOrder ->
            "rels"

        Tile.Empty ->
            "empt"
