module Game.Level.Progress exposing
    ( Progress
    , clearCurrentLevel
    , currentCompletedSeed
    , currentLevel
    , currentLevelComplete
    , currentLevelSeedType
    , currentWorldComplete
    , fromCache
    , fromLevel
    , handleIncrement
    , isFirstPlay
    , percentComplete
    , pointsFromPreviousLevel
    , reachedLevel
    , reachedLevelSeedType
    , resources
    , setCurrentLevel
    , toCache
    , worldComplete
    )

import Dict exposing (Dict)
import Game.Board.Scores as Score
import Game.Board.Tile as Tile exposing (Tile)
import Game.Config.Level as Level
import Game.Config.World as Worlds
import Game.Level.Tile as Tile exposing (TargetScore(..))
import Seed exposing (Seed)
import Utils.Dict
import Utils.List


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


toCache : Progress -> Level.Cache
toCache (Progress progress) =
    Level.toCache progress.reached


fromCache : Maybe Level.Cache -> Progress
fromCache cachedLevel =
    cachedLevel
        |> Maybe.map Level.fromCache
        |> Maybe.withDefault Level.first
        |> fromLevel


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
reachedLevel (Progress progress) =
    progress.reached


currentLevel : Progress -> Maybe Level.Id
currentLevel (Progress progress) =
    progress.current


isFirstPlay : Progress -> Bool
isFirstPlay progress =
    reachedLevel progress == Level.first


worldComplete : List Level.Id -> Progress -> Bool
worldComplete levels progress =
    levels
        |> List.reverse
        |> List.head
        |> Maybe.map (\l -> Level.isCompleted (reachedLevel progress) l)
        |> Maybe.withDefault False


currentCompletedSeed : Progress -> Seed
currentCompletedSeed progress =
    Worlds.list
        |> List.filter (\world -> worldComplete world.levels progress)
        |> List.reverse
        |> List.head
        |> Maybe.map (.world >> .seed)
        |> Maybe.withDefault Seed.Sunflower


currentWorldComplete : Level.Worlds -> Progress -> Bool
currentWorldComplete worlds (Progress { current, reached }) =
    current
        |> Maybe.map (\level -> Level.isLastLevelOfWorld worlds level && Level.isFirstLevelOfWorld reached)
        |> Maybe.withDefault False


currentLevelComplete : Progress -> Maybe Bool
currentLevelComplete (Progress { current, reached }) =
    Maybe.map (\level -> Level.isCompleted reached level) current


reachedLevelSeedType : Level.Worlds -> Progress -> Seed
reachedLevelSeedType worlds (Progress progress) =
    progress.reached
        |> Level.seedType worlds
        |> Maybe.withDefault Seed.final


currentLevelSeedType : Level.Worlds -> Progress -> Maybe Seed
currentLevelSeedType worlds (Progress progress) =
    Maybe.andThen (Level.seedType worlds) progress.current


resources : Level.Worlds -> Progress -> Maybe (List Tile)
resources worlds (Progress progress) =
    case progress.current of
        Just level ->
            Maybe.map2
                resourcesInLevels
                (Level.seedType worlds level)
                (Level.getLevels worlds level)

        Nothing ->
            Nothing


percentComplete : Level.Worlds -> Tile -> Progress -> Maybe Float
percentComplete worlds tileType ((Progress { reached }) as progress) =
    case position worlds progress of
        CurrentWorldComplete ->
            Just 100

        _ ->
            Maybe.map2 percent
                (scoresAtLevel worlds reached |> getScoreFor tileType)
                (targetWorldScores worlds reached |> Maybe.andThen (getScoreFor tileType))


percent : Int -> Int -> Float
percent a b =
    (toFloat a / toFloat b) * 100


pointsFromPreviousLevel : Level.Worlds -> Tile -> Progress -> Maybe Int
pointsFromPreviousLevel worlds tileType ((Progress { reached, current }) as progress) =
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
                    current
                        |> Maybe.andThen (targetWorldScores worlds)
                        |> Maybe.andThen tileScore

                prev =
                    current
                        |> Maybe.map (previous >> levelScores)
                        |> Maybe.andThen tileScore
            in
            Maybe.map2 (-) curr prev

        FirstLevelOfWorld ->
            current
                |> Maybe.map (Level.next worlds >> levelScores)
                |> Maybe.andThen tileScore

        MiddleLevel ->
            Maybe.map2 (-)
                (tileScore <| levelScores reached)
                (tileScore <| levelScores <| previous reached)



-- Internal


position : Level.Worlds -> Progress -> Position
position worlds ((Progress { current }) as progress) =
    if currentWorldComplete worlds progress then
        CurrentWorldComplete

    else if Maybe.map Level.isFirstLevelOfWorld current == Just True then
        FirstLevelOfWorld

    else
        MiddleLevel


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
        |> Maybe.map (Utils.Dict.mapValues <| always 0)


targetWorldScores : Level.Worlds -> Level.Id -> Maybe (Dict String Int)
targetWorldScores worlds level =
    level
        |> Level.getLevels worlds
        |> Maybe.map scoresForWorld


scoresForWorld : List Level.Level -> Dict String Int
scoresForWorld levels =
    levels
        |> List.map tileSettings
        |> List.concat
        |> totalScoresDict


totalScoresDict : List Tile.Setting -> Dict String Int
totalScoresDict =
    List.foldr accumSettings Dict.empty


accumSettings : Tile.Setting -> Dict String Int -> Dict String Int
accumSettings setting acc =
    case setting.targetScore of
        Just (TargetScore n) ->
            Utils.Dict.insertWith (+) (Tile.toString setting.tileType) n acc

        Nothing ->
            acc


secondaryResource : Seed -> Tile -> Bool
secondaryResource worldSeedType tileType =
    case Tile.seedType tileType of
        Just seed ->
            not <| worldSeedType == seed

        Nothing ->
            True


tileSettings : Level.Level -> List Tile.Setting
tileSettings =
    Level.config >> .tileSettings
