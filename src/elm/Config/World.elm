module Config.World exposing
    ( all
    , getLevel
    , levelConfig
    , list
    , number
    )

import Config.Level as Level exposing (..)
import Config.World.One as One
import Config.World.Three as Three
import Config.World.Two as Two



-- All Levels


all : Level.Worlds
all =
    Level.worlds
        [ One.world
        , Two.world
        , Three.world
        ]



-- With all Levels applied


getLevel : Level.Id -> Maybe Level
getLevel =
    Level.getLevel all


number : Level.Id -> Int
number =
    Level.number all >> Maybe.withDefault 1


list : List Level.WorldWithLevels
list =
    Level.worldsList all


levelConfig : Level.Id -> LevelConfig
levelConfig =
    getLevel
        >> Maybe.withDefault Level.default
        >> Level.config
