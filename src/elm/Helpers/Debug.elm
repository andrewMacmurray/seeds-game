module Helpers.Debug exposing (goToLevel)

import Data.Levels as Levels exposing (LevelConfig)
import Helpers.Delay as Delay
import Worlds


goToLevel : Int -> Int -> (LevelConfig -> msg) -> Cmd msg
goToLevel world level msg =
    Delay.trigger <| msg <| Worlds.levelConfig <| Levels.idFromRaw_ world level
