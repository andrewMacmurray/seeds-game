module Game.Level.Progress exposing
    ( Progress
    , clearCurrentLevel
    , currentCompletedSeed
    , currentLevel
    , currentLevelComplete
    , currentLevelSeedType
    , currentWorldComplete
    , fromLevel
    , handleIncrement
    , init
    , isFirstPlay
    , percentComplete
    , pointsFromPreviousLevel
    , reachedLevel
    , reachedLevelSeedType
    , resources
    , save
    , setCurrentLevel
    , worldIsCompleted
    )

import Dict exposing (Dict)
import Game.Board.Scores as Score
import Game.Board.Tile as Tile exposing (Tile)
import Game.Config.Level as Level
import Game.Config.World as Worlds
import Game.Level.Tile as Tile exposing (TargetScore(..))
import Ports.Cache as Cache
import Seed exposing (Seed)
import Utils.Dict as Dict
import Utils.List



-- Progress


type Progress
    = Progress State


type alias State =
    { current : Maybe Level.Id
    , reached : Level.Id
    }


type Position
    = CurrentWorldComplete
    | FirstLevelOfWorld
    | MiddleLevel



-- Cache


save : Progress -> Cmd msg
save =
    toCache >> Cache.saveProgress


toCache : Progress -> Level.Cache
toCache =
    reachedLevel >> Level.toCache


init : Maybe Level.Cache -> Progress
init =
    Maybe.map Level.fromCache
        >> Maybe.withDefault Level.first
        >> fromLevel


fromLevel : Level.Id -> Progress
fromLevel reached =
    Progress
        { current = Nothing
        , reached = reached
        }



-- Update


setCurrentLevel : Level.Id -> Progress -> Progress
setCurrentLevel level (Progress progress) =
    Progress { progress | current = Just level }


clearCurrentLevel : Progress -> Progress
clearCurrentLevel (Progress progress) =
    Progress { progress | current = Nothing }


handleIncrement : Level.Worlds -> Progress -> Progress
handleIncrement worlds (Progress progress) =
    case progress.current of
        Nothing ->
            Progress progress

        Just current ->
            Progress { progress | reached = Level.next worlds current }



--  Query


reachedLevel : Progress -> Level.Id
reachedLevel =
    progress_ >> .reached


currentLevel : Progress -> Maybe Level.Id
currentLevel =
    progress_ >> .current


progress_ : Progress -> State
progress_ (Progress p) =
    p


isFirstPlay : Progress -> Bool
isFirstPlay progress =
    reachedLevel progress == Level.first


worldIsCompleted : List Level.Id -> Progress -> Bool
worldIsCompleted levels progress =
    levels
        |> List.reverse
        |> List.head
        |> Maybe.map (levelIsCompleted progress)
        |> Maybe.withDefault False


levelIsCompleted : Progress -> Level.Id -> Bool
levelIsCompleted =
    reachedLevel >> Level.isCompleted


currentCompletedSeed : Progress -> Seed
currentCompletedSeed progress =
    Worlds.list
        |> List.filter (\world -> worldIsCompleted world.levels progress)
        |> List.reverse
        |> List.head
        |> Maybe.map (.world >> .seed)
        |> Maybe.withDefault Seed.Sunflower


currentWorldComplete : Level.Worlds -> Progress -> Bool
currentWorldComplete worlds progress =
    currentLevel progress
        |> Maybe.map (currentWorldComplete_ worlds progress)
        |> Maybe.withDefault False


currentWorldComplete_ : Level.Worlds -> Progress -> Level.Id -> Bool
currentWorldComplete_ worlds progress level =
    Level.isLastLevelOfWorld worlds level && Level.isFirstLevelOfWorld (reachedLevel progress)


currentLevelComplete : Progress -> Maybe Bool
currentLevelComplete progress =
    Maybe.map (currentLevelIsComplete_ progress) (currentLevel progress)


currentLevelIsComplete_ : Progress -> Level.Id -> Bool
currentLevelIsComplete_ =
    reachedLevel >> Level.isCompleted


reachedLevelSeedType : Level.Worlds -> Progress -> Seed
reachedLevelSeedType worlds =
    reachedLevel
        >> Level.seedType worlds
        >> Maybe.withDefault Seed.final


currentLevelSeedType : Level.Worlds -> Progress -> Maybe Seed
currentLevelSeedType worlds =
    currentLevel >> Maybe.andThen (Level.seedType worlds)


resources : Level.Worlds -> Progress -> List Tile
resources worlds =
    resources_ worlds >> Maybe.withDefault []


resources_ : Level.Worlds -> Progress -> Maybe (List Tile)
resources_ worlds progress =
    case currentLevel progress of
        Just level ->
            Maybe.map2 resourcesInLevels
                (Level.seedType worlds level)
                (Level.getLevels worlds level)

        Nothing ->
            Nothing


percentComplete : Level.Worlds -> Tile -> Progress -> Maybe Float
percentComplete worlds tileType progress =
    case position worlds progress of
        CurrentWorldComplete ->
            Just 100

        _ ->
            Maybe.map2 percent
                (currentScoreFor tileType worlds progress)
                (targetScoreFor tileType worlds progress)


currentScoreFor : Tile -> Level.Worlds -> Progress -> Maybe Int
currentScoreFor tile worlds =
    reachedLevel
        >> scoresAtLevel worlds
        >> getScoreFor tile


targetScoreFor : Tile -> Level.Worlds -> Progress -> Maybe Int
targetScoreFor tile worlds =
    reachedLevel
        >> targetWorldScores worlds
        >> Maybe.andThen (getScoreFor tile)


percent : Int -> Int -> Float
percent a b =
    (toFloat a / toFloat b) * 100


pointsFromPreviousLevel : Level.Worlds -> Tile -> Progress -> Int
pointsFromPreviousLevel worlds tile =
    pointsFromPreviousLevel_ worlds tile >> Maybe.withDefault 0


pointsFromPreviousLevel_ : Level.Worlds -> Tile -> Progress -> Maybe Int
pointsFromPreviousLevel_ worlds tileType progress =
    let
        tileScore =
            getScoreFor tileType

        levelScores =
            scoresAtLevel worlds

        previous =
            Level.previous worlds
    in
    case position worlds progress of
        CurrentWorldComplete ->
            let
                curr =
                    currentLevel progress
                        |> Maybe.andThen (targetWorldScores worlds)
                        |> Maybe.andThen tileScore

                prev =
                    currentLevel progress
                        |> Maybe.map (previous >> levelScores)
                        |> Maybe.andThen tileScore
            in
            maybeDifference curr prev

        FirstLevelOfWorld ->
            currentLevel progress
                |> Maybe.map (Level.next worlds >> levelScores)
                |> Maybe.andThen tileScore

        MiddleLevel ->
            maybeDifference
                (tileScore (levelScores (reachedLevel progress)))
                (tileScore (levelScores (previous (reachedLevel progress))))


maybeDifference : Maybe number -> Maybe number -> Maybe number
maybeDifference =
    Maybe.map2 (-)



-- Internal


position : Level.Worlds -> Progress -> Position
position worlds progress =
    if currentWorldComplete worlds progress then
        CurrentWorldComplete

    else if isAtFirstLevelOfWorld progress then
        FirstLevelOfWorld

    else
        MiddleLevel


isAtFirstLevelOfWorld : Progress -> Bool
isAtFirstLevelOfWorld progress =
    Maybe.map Level.isFirstLevelOfWorld (currentLevel progress) == Just True


getScoreFor : Tile -> Dict String Int -> Maybe Int
getScoreFor =
    Tile.toString >> Dict.get


resourcesInLevels : Seed -> List Level.Level -> List Tile
resourcesInLevels worldSeedType =
    List.map tileSettings
        >> List.concat
        >> List.filter Score.collectible
        >> List.map .tileType
        >> List.filter (secondaryResource worldSeedType)
        >> Utils.List.unique


scoresAtLevel : Level.Worlds -> Level.Id -> Dict String Int
scoresAtLevel worlds level =
    level
        |> Level.idsForWorld worlds
        |> Maybe.withDefault []
        |> List.filter (Level.isCompleted level)
        |> List.map (Level.getLevel worlds >> Maybe.map tileSettings >> Maybe.withDefault [])
        |> List.concat
        |> totalScoresDict
        |> combineWithEmptyScores worlds level


combineWithEmptyScores : Level.Worlds -> Level.Id -> Dict String Int -> Dict String Int
combineWithEmptyScores worlds levels scores =
    scoresAtBeginningOfWorld worlds levels
        |> Maybe.withDefault Dict.empty
        |> Dict.union scores


scoresAtBeginningOfWorld : Level.Worlds -> Level.Id -> Maybe (Dict String Int)
scoresAtBeginningOfWorld worlds level =
    targetWorldScores worlds level
        |> Maybe.map (Dict.mapValues (always 0))


targetWorldScores : Level.Worlds -> Level.Id -> Maybe (Dict String Int)
targetWorldScores worlds =
    Level.getLevels worlds >> Maybe.map scoresForWorld


scoresForWorld : List Level.Level -> Dict String Int
scoresForWorld =
    List.map tileSettings
        >> List.concat
        >> totalScoresDict


totalScoresDict : List Tile.Setting -> Dict String Int
totalScoresDict =
    List.foldr accumSettings Dict.empty


accumSettings : Tile.Setting -> Dict String Int -> Dict String Int
accumSettings setting acc =
    case setting.targetScore of
        Just score ->
            Dict.insertWith (+) (Tile.toString setting.tileType) (Tile.targetScore score) acc

        Nothing ->
            acc


secondaryResource : Seed -> Tile -> Bool
secondaryResource worldSeedType tileType =
    case Tile.seedType tileType of
        Just seed ->
            not (worldSeedType == seed)

        Nothing ->
            True


tileSettings : Level.Level -> List Tile.Setting
tileSettings =
    Level.config >> .tileSettings
