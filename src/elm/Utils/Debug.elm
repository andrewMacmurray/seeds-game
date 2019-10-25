module Utils.Debug exposing (goToLevel)

import Config.Levels as Levels exposing (LevelConfig)
import Config.Worlds
import Ports
import Utils.Delay as Delay



-- Debug


goToLevel : Int -> Int -> (LevelConfig -> msg) -> Cmd msg
goToLevel world level msg =
    Cmd.batch
        [ Delay.trigger <| msg <| Worlds.levelConfig <| Levels.idFromRaw_ world level
        , setProgress world level
        ]


setProgress : Int -> Int -> Cmd msg
setProgress world level =
    Ports.cacheProgress <| Levels.toCache <| Levels.idFromRaw_ world level
