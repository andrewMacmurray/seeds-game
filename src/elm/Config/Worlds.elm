module Config.Worlds exposing
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

import Config.Levels as Levels exposing (..)
import Config.Worlds.One as One
import Config.Worlds.Three as Three
import Config.Worlds.Two as Two
import Scenes.Tutorial as Tutorial
import Scenes.Tutorial.Rain as Rain
import Scenes.Tutorial.Seed as Seed
import Scenes.Tutorial.SeedPod as SeedPod
import Scenes.Tutorial.Sun as Sun
import Seed exposing (Seed)



-- All Levels


all : Levels.Worlds
all =
    Levels.worlds
        [ One.world
        , Two.world
        , Three.world
        ]



-- With all Levels applied


getLevel : Levels.Id -> Maybe Level
getLevel =
    Levels.getLevel all


tutorial : Levels.Id -> Maybe Tutorial.Config
tutorial =
    Levels.tutorial all >> Maybe.map tutorialConfig_


number : Levels.Id -> Maybe Int
number =
    Levels.number all


list : List ( WorldConfig, List Levels.Id )
list =
    Levels.worldsList all


next : Levels.Id -> Levels.Id
next =
    Levels.next all


previous : Levels.Id -> Levels.Id
previous =
    Levels.previous all


seedType : Levels.Id -> Maybe Seed
seedType =
    Levels.seedType all


levelConfig : Levels.Id -> LevelConfig
levelConfig =
    getLevel
        >> Maybe.withDefault Levels.default
        >> Levels.config



-- Tutorial Config


tutorialConfig_ : Levels.Tutorial -> Tutorial.Config
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
