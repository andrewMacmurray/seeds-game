module Data.Levels exposing
    ( Cache
    , Key
    , Level
    , LevelConfig
    , Tutorial(..)
    , World
    , WorldConfig
    , Worlds
    , completed
    , config
    , empty
    , fromCache
    , getKeysForWorld
    , getLevel
    , getLevels
    , isFirstLevelOfWorld
    , isLastLevelOfWorld
    , keyFromRaw_
    , level
    , next
    , number
    , previous
    , reached
    , seedType
    , toCache
    , toId
    , tutorial
    , withTutorial
    , world
    , worlds
    , worldsList
    )

import Css.Color exposing (Color)
import Data.Board.Types exposing (BoardDimensions, Coord, SeedType, TileType)
import Data.Level.Setting exposing (Probability, TargetScore, TileSetting)
import Dict exposing (Dict)



-- Level Key


type Key
    = Key Cache


type alias Cache =
    { worldId : Int
    , levelId : Int
    }


fromCache : Cache -> Key
fromCache { worldId, levelId } =
    Key <| Cache worldId levelId


toCache : Key -> Cache
toCache key =
    { worldId = worldId_ key
    , levelId = levelId_ key
    }


empty : Key
empty =
    keyFromRaw_ 1 1


toId : Key -> String
toId key =
    String.join "-"
        [ "world"
        , String.fromInt <| worldId_ key
        , "level"
        , String.fromInt <| levelId_ key
        ]



-- Query Worlds


type Worlds
    = Worlds (Dict Int World)


type World
    = World
        { levels : Levels
        , seedType : SeedType
        , backdropColor : Color
        , textColor : Color
        , textCompleteColor : Color
        , textBackgroundColor : Color
        }


type alias WorldConfig =
    { seedType : SeedType
    , backdropColor : Color
    , textColor : Color
    , textCompleteColor : Color
    , textBackgroundColor : Color
    }


type alias Levels =
    Dict Int Level


type Level
    = Level
        { tiles : List TileSetting
        , walls : List ( Color, Coord )
        , boardDimensions : BoardDimensions
        , moves : Int
        , tutorial : Maybe Tutorial
        }


type alias LevelConfig =
    { tiles : List TileSetting
    , walls : List ( Color, Coord )
    , boardDimensions : BoardDimensions
    , moves : Int
    }


type Tutorial
    = Sun
    | Rain
    | Seed
    | SeedPod



-- Query Worlds And Levels with Key


getLevel : Worlds -> Key -> Maybe Level
getLevel worlds_ key =
    worlds_
        |> getWorld_ key
        |> Maybe.map unboxLevels_
        |> Maybe.andThen (getLevel_ key)


getLevels : Worlds -> Key -> Maybe (List Level)
getLevels worlds_ key =
    worlds_
        |> getWorld_ key
        |> Maybe.map (unboxLevels_ >> Dict.toList >> List.map Tuple.second)


getKeysForWorld : Worlds -> Key -> Maybe (List Key)
getKeysForWorld worlds_ key =
    worlds_
        |> getWorld_ key
        |> Maybe.map (unboxLevels_ >> levelKeys (worldId_ key))


getWorld_ : Key -> Worlds -> Maybe World
getWorld_ key worlds_ =
    Dict.get (worldId_ key) (unboxWorlds_ worlds_)


getLevel_ : Key -> Levels -> Maybe Level
getLevel_ key levels =
    Dict.get (levelId_ key) levels


isLastLevelOfWorld : Worlds -> Key -> Bool
isLastLevelOfWorld worlds_ key =
    worlds_
        |> getWorld_ key
        |> Maybe.map unboxLevels_
        |> Maybe.map (\l -> Dict.size l == levelId_ key)
        |> Maybe.withDefault False


isFirstLevelOfWorld : Key -> Bool
isFirstLevelOfWorld key =
    levelId_ key == 1


next : Worlds -> Key -> Key
next worlds_ key =
    if isLastLevelOfWorld worlds_ key then
        keyFromRaw_ (worldId_ key + 1) 1

    else
        keyFromRaw_ (worldId_ key) (levelId_ key + 1)


previous : Worlds -> Key -> Key
previous worlds_ key =
    if isFirstLevelOfWorld key then
        let
            wId =
                worldId_ key - 1

            lId =
                getWorldSizeFromIndex_ worlds_ wId |> Maybe.withDefault 1
        in
        keyFromRaw_ wId lId

    else
        keyFromRaw_ (worldId_ key) (levelId_ key - 1)


reached : Key -> Key -> Bool
reached (Key current) (Key target) =
    current.worldId > target.worldId || (current.worldId == target.worldId && current.levelId >= target.levelId)


completed : Key -> Key -> Bool
completed (Key current) (Key target) =
    current.worldId > target.worldId || (current.worldId == target.worldId && current.levelId > target.levelId)


tutorial : Worlds -> Key -> Maybe Tutorial
tutorial worlds_ =
    getLevel worlds_ >> Maybe.andThen tutorial_


tutorial_ : Level -> Maybe Tutorial
tutorial_ (Level l) =
    l.tutorial


config : Level -> LevelConfig
config (Level l) =
    { tiles = l.tiles
    , walls = l.walls
    , boardDimensions = l.boardDimensions
    , moves = l.moves
    }


seedType : Worlds -> Key -> Maybe SeedType
seedType worlds_ key =
    worlds_
        |> getWorld_ key
        |> Maybe.map (\(World w) -> w.seedType)



-- Construct Worlds And Levels


worlds : List World -> Worlds
worlds =
    List.indexedMap (\i w -> ( i + 1, w ))
        >> Dict.fromList
        >> Worlds


world : WorldConfig -> List Level -> World
world c levels =
    World
        { seedType = c.seedType
        , backdropColor = c.backdropColor
        , textColor = c.textColor
        , textCompleteColor = c.textCompleteColor
        , textBackgroundColor = c.textBackgroundColor
        , levels = makeLevels_ levels
        }


makeLevels_ : List Level -> Levels
makeLevels_ levels =
    levels
        |> List.indexedMap (\i l -> ( i + 1, l ))
        |> Dict.fromList


level : LevelConfig -> Level
level levelConfig =
    Level
        { tiles = levelConfig.tiles
        , walls = levelConfig.walls
        , boardDimensions = levelConfig.boardDimensions
        , moves = levelConfig.moves
        , tutorial = Nothing
        }


withTutorial : Tutorial -> LevelConfig -> Level
withTutorial t levelConfig =
    Level
        { tiles = levelConfig.tiles
        , walls = levelConfig.walls
        , boardDimensions = levelConfig.boardDimensions
        , moves = levelConfig.moves
        , tutorial = Just t
        }



-- Renderable World Data


number : Worlds -> Key -> Maybe Int
number worlds_ key =
    if levelExists worlds_ key then
        (worldId_ key - 1)
            |> List.range 1
            |> List.map (getWorldSizeFromIndex_ worlds_)
            |> List.foldr accumulateSize (levelId_ key)
            |> Just

    else
        Nothing


accumulateSize : Maybe Int -> Int -> Int
accumulateSize size total =
    total + Maybe.withDefault 0 size


getWorldSizeFromIndex_ : Worlds -> Int -> Maybe Int
getWorldSizeFromIndex_ worlds_ i =
    getWorld_ (keyFromRaw_ i 1) worlds_ |> Maybe.map worldSize


worldsList : Worlds -> List ( WorldConfig, List Key )
worldsList worlds_ =
    worlds_
        |> unboxWorlds_
        |> Dict.toList
        |> List.map configWithKeys


configWithKeys : ( Int, World ) -> ( WorldConfig, List Key )
configWithKeys ( worldIndex, world_ ) =
    ( worldConfig world_
    , levelKeys worldIndex <| unboxLevels_ world_
    )


levelKeys : Int -> Levels -> List Key
levelKeys worldIndex levels =
    levels
        |> Dict.toList
        |> List.map Tuple.first
        |> List.map (keyFromRaw_ worldIndex)


worldSize : World -> Int
worldSize =
    Dict.size << unboxLevels_



-- Helpers


worldConfig : World -> WorldConfig
worldConfig (World w) =
    { seedType = w.seedType
    , backdropColor = w.backdropColor
    , textColor = w.textColor
    , textCompleteColor = w.textCompleteColor
    , textBackgroundColor = w.textBackgroundColor
    }


levelExists : Worlds -> Key -> Bool
levelExists w key =
    case getLevel w key of
        Nothing ->
            False

        _ ->
            True


unboxLevels_ : World -> Levels
unboxLevels_ (World w) =
    w.levels


levelId_ : Key -> Int
levelId_ (Key { levelId }) =
    levelId


unboxWorlds_ : Worlds -> Dict Int World
unboxWorlds_ (Worlds w) =
    w


worldId_ : Key -> Int
worldId_ (Key { worldId }) =
    worldId


keyFromRaw_ : Int -> Int -> Key
keyFromRaw_ worldId levelId =
    Key <| Cache worldId levelId
