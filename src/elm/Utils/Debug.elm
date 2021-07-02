module Utils.Debug exposing
    ( goToHub
    , goToLevel
    , move
    , progress
    , setProgress
    , tileState
    , trigger
    )

import Element exposing (..)
import Element.Font as Font
import Game.Board.Move as Move exposing (Move)
import Game.Board.Tile as Tile
import Game.Config.Level as Level exposing (LevelConfig)
import Game.Config.World as World
import Game.Level.Progress as Progress exposing (Progress)
import Ports.Cache as Cache
import Utils.Update as Update



-- Trigger


trigger : msg -> ( model, Cmd msg ) -> ( model, Cmd msg )
trigger msg ( model, cmd ) =
    ( model, Cmd.batch [ cmd, Update.trigger msg ] )



-- Progress and Levels


goToLevel : Int -> Int -> (LevelConfig -> msg) -> ( model, Cmd msg ) -> ( model, Cmd msg )
goToLevel world level msg ( model, cmd ) =
    ( model, Cmd.batch [ goToLevel_ world level msg, cmd ] )


goToHub : Int -> Int -> (Level.Id -> msg) -> ( model, Cmd msg ) -> ( model, Cmd msg )
goToHub world level msg ( model, cmd ) =
    ( model, Cmd.batch [ Update.trigger (msg (Level.build_ world level)), cmd ] )


goToLevel_ : Int -> Int -> (LevelConfig -> msg) -> Cmd msg
goToLevel_ world level msg =
    Cmd.batch
        [ Update.trigger (msg (levelConfig world level))
        , setProgress world level
        ]


levelConfig : Int -> Int -> LevelConfig
levelConfig world =
    Level.build_ world >> World.levelConfig


setProgress : Int -> Int -> Cmd msg
setProgress world level =
    Level.build_ world level
        |> Level.toCache
        |> Cache.saveProgress


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
        Tile.Static _ ->
            "stat"

        Tile.Dragging _ _ _ ->
            "drag"

        Tile.Leaving _ _ ->
            "leav"

        Tile.Falling _ _ ->
            "fall"

        Tile.Entering _ ->
            "entr"

        Tile.Growing _ _ ->
            "grow"

        Tile.Active _ ->
            "actv"

        Tile.Releasing _ _ ->
            "rels"

        Tile.Empty ->
            "empt"
