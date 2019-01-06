module Worlds exposing
    ( all
    , getKeysForWorld
    , getLevel
    , getLevels
    , isLastLevelOfWorld
    , levelConfig
    , list
    , next
    , number
    , previous
    , seedType
    , tutorial
    )

import Data.Board.Types exposing (SeedType)
import Data.Levels as Levels exposing (..)
import Scenes.Tutorial as Tutorial
import Scenes.Tutorial.Rain as Rain
import Scenes.Tutorial.Seed as Seed
import Scenes.Tutorial.SeedPod as SeedPod
import Scenes.Tutorial.Sun as Sun
import Worlds.One as One
import Worlds.Three as Three
import Worlds.Two as Two



-- All Levels


all : Levels.Worlds
all =
    Levels.worlds
        [ One.world
        , Two.world
        , Three.world
        ]



-- With all Levels applied


getLevel : Key -> Maybe Level
getLevel =
    Levels.getLevel all


getLevels : Key -> Maybe (List Level)
getLevels =
    Levels.getLevels all


getKeysForWorld : Key -> Maybe (List Key)
getKeysForWorld =
    Levels.getKeysForWorld all


isLastLevelOfWorld : Key -> Bool
isLastLevelOfWorld =
    Levels.isLastLevelOfWorld all


tutorial : Key -> Maybe Tutorial.Config
tutorial =
    Levels.tutorial all >> Maybe.map tutorialConfig_


number : Key -> Maybe Int
number =
    Levels.number all


list : List ( WorldConfig, List Key )
list =
    Levels.worldsList all


next : Key -> Key
next =
    Levels.next all


previous : Key -> Key
previous =
    Levels.previous all


seedType : Key -> Maybe SeedType
seedType =
    Levels.seedType all


levelConfig : Key -> LevelConfig
levelConfig =
    getLevel
        >> Maybe.withDefault One.default
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
