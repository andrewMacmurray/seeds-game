module Utils.Debug exposing (goToLevel)

import Config.Level as Level exposing (Config)
import Config.World as World
import Ports
import Utils.Delay as Delay



-- Debug


goToLevel : Int -> Int -> (Config -> msg) -> Cmd msg
goToLevel world level msg =
    Cmd.batch
        [ Delay.trigger <| msg <| World.levelConfig <| Level.idFromRaw_ world level
        , setProgress world level
        ]


setProgress : Int -> Int -> Cmd msg
setProgress world level =
    Ports.cacheProgress <| Level.toCache <| Level.idFromRaw_ world level
