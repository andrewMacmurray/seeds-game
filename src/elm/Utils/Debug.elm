module Utils.Debug exposing
    ( goToLevel
    , move
    , setProgress
    )

import Board.Move as Move exposing (Move)
import Config.Level as Level exposing (LevelConfig)
import Config.World as World
import Html exposing (Html)
import Html.Attributes
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
    Level.idFromRaw_ world >> World.levelConfig


setProgress : Int -> Int -> Cmd msg
setProgress world level =
    Level.idFromRaw_ world level
        |> Level.toCache
        |> Ports.cacheProgress



-- Board


move : Move -> Html msg
move move_ =
    let
        x =
            Move.x move_ |> String.fromInt

        y =
            Move.y move_ |> String.fromInt
    in
    Html.div
        [ Html.Attributes.class "absolute flex justify-center tc left-0 right-0 f7" ]
        [ Html.text ("x" ++ x ++ "y" ++ y) ]
