module Utils.Debug exposing
    ( goToHub
    , goToLevel
    )

import Config.Level as Level exposing (Config)
import Config.World as World
import Ports
import Utils.Delay as Delay



-- Debug


goToLevel : Int -> Int -> (Config -> msg) -> Cmd msg
goToLevel world level msg =
    Cmd.batch
        [ Delay.trigger <| msg <| World.levelConfig <| levelId world level
        , setProgress world level
        ]


goToHub : Int -> Int -> (Level.Id -> msg) -> Cmd msg
goToHub world level msg =
    Cmd.batch
        [ Delay.trigger <| msg (levelId world level)
        , setProgress world level
        ]



-- Helpers


setProgress : Int -> Int -> Cmd msg
setProgress world level =
    Ports.cacheProgress <| Level.toCache <| levelId world level


levelId : Int -> Int -> Level.Id
levelId =
    Level.idFromRaw_
