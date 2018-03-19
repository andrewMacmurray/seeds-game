module Data.Hub.World exposing (..)

import Helpers.Dict exposing (indexedDictFrom)
import Scenes.Hub.Types exposing (..)


makeWorldLevels : List LevelData -> WorldLevels
makeWorldLevels =
    indexedDictFrom 1
