module Config.World exposing
    ( all
    , getLevel
    , levelConfig
    , list
    , next
    , number
    , previous
    , seedType
    , tutorial
    )

import Config.Level as Level exposing (..)
import Config.World.One as One
import Config.World.Three as Three
import Config.World.Two as Two
import Scenes.Tutorial as Tutorial
import Scenes.Tutorial.Rain as Rain
import Scenes.Tutorial.Seed as Seed
import Scenes.Tutorial.SeedPod as SeedPod
import Scenes.Tutorial.Sun as Sun
import Seed exposing (Seed)



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


tutorial : Level.Id -> Maybe Tutorial.Config
tutorial =
    Level.tutorial all >> Maybe.map tutorialConfig_


number : Level.Id -> Maybe Int
number =
    Level.number all


list : List ( WorldConfig, List Level.Id )
list =
    Level.worldsList all


next : Level.Id -> Level.Id
next =
    Level.next all


previous : Level.Id -> Level.Id
previous =
    Level.previous all


seedType : Level.Id -> Maybe Seed
seedType =
    Level.seedType all


levelConfig : Level.Id -> LevelConfig
levelConfig =
    getLevel
        >> Maybe.withDefault Level.default
        >> Level.config



-- Tutorial Config


tutorialConfig_ : Level.Tutorial -> Tutorial.Config
tutorialConfig_ tutorial_ =
    case tutorial_ of
        Sun ->
            Sun.config

        Rain ->
            Rain.config

        Seed ->
            Seed.config

        SeedPod ->
            SeedPod.config
