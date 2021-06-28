module Game.Config.Level exposing
    ( Cache
    , Id
    , Level
    , LevelConfig
    , World
    , WorldConfig
    , WorldWithLevels
    , Worlds
    , build_
    , config
    , default
    , first
    , fromCache
    , getLevel
    , getLevels
    , idsForWorld
    , isCompleted
    , isFirstLevelOfWorld
    , isLastLevelOfWorld
    , isReached
    , level
    , next
    , number
    , previous
    , seedType
    , toCache
    , toString
    , withTutorial
    , world
    , worlds
    , worldsList
    )

import Dict exposing (Dict)
import Element exposing (Color)
import Game.Board as Board
import Game.Board.Wall as Wall
import Game.Level.Tile as Tile
import Game.Level.Tile.Constant as Start
import Game.Level.Tutorial as Tutorial exposing (Tutorial)
import Seed exposing (Seed)



-- World and Level Config


type Id
    = Id Cache


type alias Cache =
    { worldId : Int
    , levelId : Int
    }


type Worlds
    = Worlds (Dict Int World)


type World
    = World
        { levels : Levels
        , seed : Seed
        , backdropColor : Color
        , textColor : Color
        , textCompleteColor : Color
        , textBackgroundColor : Color
        }


type alias WorldConfig =
    { seed : Seed
    , backdropColor : Color
    , textColor : Color
    , textCompleteColor : Color
    , textBackgroundColor : Color
    }


type alias Levels =
    Dict Int Level


type Level
    = Level LevelConfig


type alias LevelInitConfig =
    { tileSettings : List Tile.Setting
    , startTiles : List Start.Tile
    , walls : List Wall.Config
    , boardSize : Board.Size
    , moves : Int
    }


type alias LevelConfig =
    { tileSettings : List Tile.Setting
    , startTiles : List Start.Tile
    , walls : List Wall.Config
    , boardSize : Board.Size
    , moves : Int
    , tutorial : Tutorial.Tutorial
    }


type alias WorldWithLevels =
    { world : WorldConfig
    , levels : List Id
    }



-- Level Id


fromCache : Cache -> Id
fromCache { worldId, levelId } =
    Id (Cache worldId levelId)


toCache : Id -> Cache
toCache key =
    { worldId = worldId_ key
    , levelId = levelId_ key
    }


first : Id
first =
    build_ 1 1


toString : Id -> String
toString key =
    String.join "-"
        [ "world"
        , String.fromInt (worldId_ key)
        , "level"
        , String.fromInt (levelId_ key)
        ]



-- Construct


worlds : List World -> Worlds
worlds =
    List.indexedMap (\i w -> ( i + 1, w ))
        >> Dict.fromList
        >> Worlds


world : WorldConfig -> List Level -> World
world c levels =
    World
        { seed = c.seed
        , backdropColor = c.backdropColor
        , textColor = c.textColor
        , textCompleteColor = c.textCompleteColor
        , textBackgroundColor = c.textBackgroundColor
        , levels = makeLevels_ levels
        }


level : LevelInitConfig -> Level
level l =
    Level
        { tileSettings = l.tileSettings
        , walls = l.walls
        , startTiles = l.startTiles
        , boardSize = l.boardSize
        , moves = l.moves
        , tutorial = Tutorial.none
        }


withTutorial : Tutorial -> LevelInitConfig -> Level
withTutorial tutorial l =
    Level
        { tileSettings = l.tileSettings
        , walls = l.walls
        , startTiles = l.startTiles
        , boardSize = l.boardSize
        , moves = l.moves
        , tutorial = tutorial
        }


makeLevels_ : List Level -> Levels
makeLevels_ levels =
    levels
        |> List.indexedMap (\i l -> ( i + 1, l ))
        |> Dict.fromList


default : Level
default =
    level
        { walls = []
        , moves = 10
        , boardSize = { x = 8, y = 8 }
        , startTiles = []
        , tileSettings =
            [ Tile.rain
                { probability = 25
                , targetScore = 30
                }
            , Tile.seed
                { seed = Seed.Sunflower
                , probability = 25
                , targetScore = 50
                }
            , Tile.sun
                { probability = 25
                , targetScore = 30
                }
            , Tile.seedPod
                { probability = 25
                }
            ]
        }



-- Query


getLevel : Worlds -> Id -> Maybe Level
getLevel worlds_ id =
    worlds_
        |> getWorld_ id
        |> Maybe.map unboxLevels_
        |> Maybe.andThen (getLevel_ id)


getLevels : Worlds -> Id -> Maybe (List Level)
getLevels worlds_ id =
    worlds_
        |> getWorld_ id
        |> Maybe.map (unboxLevels_ >> Dict.toList >> List.map Tuple.second)


idsForWorld : Worlds -> Id -> Maybe (List Id)
idsForWorld worlds_ id =
    worlds_
        |> getWorld_ id
        |> Maybe.map (unboxLevels_ >> levelKeys (worldId_ id))


getWorld_ : Id -> Worlds -> Maybe World
getWorld_ id worlds_ =
    Dict.get (worldId_ id) (unboxWorlds_ worlds_)


getLevel_ : Id -> Levels -> Maybe Level
getLevel_ id levels =
    Dict.get (levelId_ id) levels


isLastLevelOfWorld : Worlds -> Id -> Bool
isLastLevelOfWorld worlds_ id =
    worlds_
        |> getWorld_ id
        |> Maybe.map unboxLevels_
        |> Maybe.map (\l -> Dict.size l == levelId_ id)
        |> Maybe.withDefault False


isFirstLevelOfWorld : Id -> Bool
isFirstLevelOfWorld id =
    levelId_ id == 1


next : Worlds -> Id -> Id
next worlds_ id =
    if isLastLevelOfWorld worlds_ id then
        build_ (worldId_ id + 1) 1

    else
        build_ (worldId_ id) (levelId_ id + 1)


previous : Worlds -> Id -> Id
previous worlds_ id =
    if isFirstLevelOfWorld id then
        let
            wId =
                worldId_ id - 1

            lId =
                getWorldSizeFromIndex_ worlds_ wId |> Maybe.withDefault 1
        in
        build_ wId lId

    else
        build_ (worldId_ id) (levelId_ id - 1)


isReached : Id -> Id -> Bool
isReached (Id current) (Id target) =
    current.worldId > target.worldId || (current.worldId == target.worldId && current.levelId >= target.levelId)


isCompleted : Id -> Id -> Bool
isCompleted (Id current) (Id target) =
    current.worldId > target.worldId || (current.worldId == target.worldId && current.levelId > target.levelId)


config : Level -> LevelConfig
config (Level l) =
    l


seedType : Worlds -> Id -> Maybe Seed
seedType worlds_ id =
    worlds_
        |> getWorld_ id
        |> Maybe.map (\(World w) -> w.seed)


number : Worlds -> Id -> Maybe Int
number worlds_ id =
    if levelExists worlds_ id then
        (worldId_ id - 1)
            |> List.range 1
            |> List.map (getWorldSizeFromIndex_ worlds_)
            |> List.foldr accumulateSize (levelId_ id)
            |> Just

    else
        Nothing


accumulateSize : Maybe Int -> Int -> Int
accumulateSize size total =
    total + Maybe.withDefault 0 size


getWorldSizeFromIndex_ : Worlds -> Int -> Maybe Int
getWorldSizeFromIndex_ worlds_ i =
    getWorld_ (build_ i 1) worlds_ |> Maybe.map worldSize


worldsList : Worlds -> List WorldWithLevels
worldsList worlds_ =
    worlds_
        |> unboxWorlds_
        |> Dict.toList
        |> List.map worldWithLevels


worldWithLevels : ( Int, World ) -> WorldWithLevels
worldWithLevels ( worldIndex, world_ ) =
    { world = worldConfig world_
    , levels = levelKeys worldIndex (unboxLevels_ world_)
    }


levelKeys : Int -> Levels -> List Id
levelKeys worldIndex levels =
    levels
        |> Dict.toList
        |> List.map Tuple.first
        |> List.map (build_ worldIndex)


worldSize : World -> Int
worldSize =
    Dict.size << unboxLevels_



-- Helpers


worldConfig : World -> WorldConfig
worldConfig (World w) =
    { seed = w.seed
    , backdropColor = w.backdropColor
    , textColor = w.textColor
    , textCompleteColor = w.textCompleteColor
    , textBackgroundColor = w.textBackgroundColor
    }


levelExists : Worlds -> Id -> Bool
levelExists w id =
    case getLevel w id of
        Nothing ->
            False

        _ ->
            True


unboxLevels_ : World -> Levels
unboxLevels_ (World w) =
    w.levels


levelId_ : Id -> Int
levelId_ (Id { levelId }) =
    levelId


unboxWorlds_ : Worlds -> Dict Int World
unboxWorlds_ (Worlds w) =
    w


worldId_ : Id -> Int
worldId_ (Id { worldId }) =
    worldId


build_ : Int -> Int -> Id
build_ worldId levelId =
    Id (Cache worldId levelId)
