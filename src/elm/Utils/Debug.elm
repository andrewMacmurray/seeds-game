module Utils.Debug exposing (goToLevel)

import Config.Level as Level exposing (LevelConfig)
import Config.World
import Ports
import Utils.Delay as Delay



-- Debug


goToLevel : Int -> Int -> (LevelConfig -> msg) -> Cmd msg
goToLevel world level msg =
    Cmd.batch
        [ Delay.trigger <| msg <| Worlds.levelConfig <| Level.idFromRaw_ world level
        , setProgress world level
        ]


setProgress : Int -> Int -> Cmd msg
setProgress world level =
    Ports.cacheProgress <| Level.toCache <| Level.idFromRaw_ world level
