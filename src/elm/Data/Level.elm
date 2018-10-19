module Data.Level exposing
    ( Cache
    , Key
    , Level
    , LevelConfig
    , World
    , WorldConfig
    , Worlds
    , completed
    , config
    , fromCache
    , getLevel
    , isLastLevelOfWorld
    , number
    , reached
    , seedType
    , toCache
    , toId
    , worldsToList
    )

import Css.Color as Css
import Data.Board.Types exposing (BoardDimensions, Coord, SeedType, TileType)
import Data.Level.Types exposing (Probability, TargetScore, TileSetting)
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
        , backdropColor : Css.Color
        , textColor : Css.Color
        , textCompleteColor : Css.Color
        , textBackgroundColor : Css.Color
        }


type alias WorldConfig =
    { seedType : SeedType
    , backdropColor : Css.Color
    , textColor : Css.Color
    , textCompleteColor : Css.Color
    , textBackgroundColor : Css.Color
    }


type alias Levels =
    Dict Int Level


type Level
    = Level
        { tiles : List TileSetting
        , walls : List ( Css.Color, Coord )
        , boardDimensions : BoardDimensions
        , moves : Int
        , tutorial : Maybe Tutorial
        }


type alias LevelConfig =
    { tiles : List TileSetting
    , walls : List ( Css.Color, Coord )
    , boardDimensions : BoardDimensions
    , moves : Int
    }


type Tutorial
    = Sun
    | Rain
    | Seed
    | SeedPod
    | Square


getLevel : Worlds -> Key -> Maybe Level
getLevel worlds_ key =
    worlds_
        |> getWorld_ key
        |> Maybe.map unboxLevels_
        |> Maybe.andThen (getLevel_ key)


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


reached : Key -> Key -> Bool
reached (Key current) (Key target) =
    current.worldId > target.worldId || (current.worldId == target.worldId && current.levelId >= target.levelId)


completed : Key -> Key -> Bool
completed (Key current) (Key target) =
    current.worldId > target.worldId || (current.worldId == target.worldId && current.levelId > target.levelId)


tutorial : Worlds -> Key -> Maybe Tutorial
tutorial worlds_ key =
    key
        |> getLevel worlds_
        |> Maybe.andThen tutorial_


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
        worldId_ key
            |> List.range 1
            |> List.map (getWorldSizeFromIndex_ worlds_)
            |> List.foldr (\size total -> total + Maybe.withDefault 0 size) (levelId_ key)
            |> Just

    else
        Nothing


getWorldSizeFromIndex_ : Worlds -> Int -> Maybe Int
getWorldSizeFromIndex_ worlds_ i =
    getWorld_ (keyFromRaw i 1) worlds_ |> Maybe.map worldSize


seedType : Worlds -> Key -> Maybe SeedType
seedType worlds_ key =
    worlds_
        |> getWorld_ key
        |> Maybe.map (\(World w) -> w.seedType)


worldsToList : Worlds -> List ( WorldConfig, List ( Key, Level ) )
worldsToList worlds_ =
    worlds_
        |> unboxWorlds_
        |> Dict.toList
        |> List.map (\( wIndex, w ) -> ( worldConfig w, levelsToList wIndex <| unboxLevels_ w ))


levelsToList : Int -> Levels -> List ( Key, Level )
levelsToList worldIndex levels =
    levels
        |> Dict.toList
        |> List.map (Tuple.mapFirst (keyFromRaw worldIndex))


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


keyFromRaw : Int -> Int -> Key
keyFromRaw worldId levelId =
    Key <| Cache worldId levelId
