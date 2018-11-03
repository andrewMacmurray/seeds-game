module Data.Progress exposing
    ( Progress
    , clearCurrentLevel
    , currentLevel
    , currentLevelComplete
    , currentLevelSeedType
    , fromCache
    , handleIncrement
    , percentComplete
    , pointsFromPreviousLevel
    , reachedLevel
    , resources
    , seedType
    , setCurrentLevel
    , toCache
    )

import Data.Board.Score as Score
import Data.Board.Tile as Tile
import Data.Board.Types exposing (SeedType, TileType)
import Data.Level.Types exposing (TargetScore(..), TileSetting)
import Data.Levels as Levels
import Dict exposing (Dict)
import Helpers.Dict
import Helpers.List


type Progress
    = Progress ProgressState


type alias ProgressState =
    { current : Maybe Levels.Key
    , reached : Levels.Key
    }



-- Cache


toCache : Progress -> Levels.Cache
toCache (Progress progress) =
    Levels.toCache progress.reached


fromCache : Maybe Levels.Cache -> Progress
fromCache cachedLevel =
    cachedLevel
        |> Maybe.map Levels.fromCache
        |> Maybe.withDefault Levels.empty
        |> fromLevel


fromLevel : Levels.Key -> Progress
fromLevel reached =
    Progress
        { current = Nothing
        , reached = reached
        }



-- Update


setCurrentLevel : Levels.Key -> Progress -> Progress
setCurrentLevel level (Progress progress) =
    Progress { progress | current = Just level }


clearCurrentLevel : Progress -> Progress
clearCurrentLevel (Progress progress) =
    Progress { progress | current = Nothing }


handleIncrement : Levels.Worlds -> Progress -> Progress
handleIncrement worlds (Progress progress) =
    case progress.current of
        Nothing ->
            Progress progress

        Just current ->
            Progress { progress | reached = Levels.next worlds current }



--  Query


reachedLevel : Progress -> Levels.Key
reachedLevel (Progress progress) =
    progress.reached


currentLevel : Progress -> Maybe Levels.Key
currentLevel (Progress progress) =
    progress.current


currentLevelComplete : Progress -> Bool
currentLevelComplete (Progress progress) =
    progress.current
        |> Maybe.map (\l -> Levels.completed l progress.reached)
        |> Maybe.withDefault False


seedType : Levels.Worlds -> Progress -> Maybe SeedType
seedType worlds (Progress progress) =
    withLevelOffset worlds progress |> Levels.seedType worlds


currentLevelSeedType : Levels.Worlds -> Progress -> Maybe SeedType
currentLevelSeedType worlds (Progress progress) =
    Maybe.andThen (Levels.seedType worlds) progress.current


resources : Levels.Worlds -> Progress -> Maybe (List TileType)
resources worlds (Progress progress) =
    Maybe.map2
        resourcesInLevels
        (Levels.seedType worlds <| withLevelOffset worlds progress)
        (Levels.getLevels worlds <| withLevelOffset worlds progress)


percentComplete : Levels.Worlds -> TileType -> Progress -> Float
percentComplete worlds tileType (Progress progress) =
    let
        targetScores =
            targetWorldScores worlds progress.reached |> Maybe.andThen (getScoreFor tileType)

        currentScores =
            scoresAtLevel worlds progress.reached |> getScoreFor tileType
    in
    if atFinalLevelOfWorld worlds progress then
        100

    else if atFirstLevelOfWorld progress then
        0

    else
        Maybe.map2 percent currentScores targetScores |> Maybe.withDefault 0


percent : Int -> Int -> Float
percent a b =
    (toFloat a / toFloat b) * 100


pointsFromPreviousLevel : Levels.Worlds -> TileType -> Progress -> Maybe Int
pointsFromPreviousLevel worlds tileType (Progress progress) =
    if atFinalLevelOfWorld worlds progress then
        let
            curr =
                progress.current
                    |> Maybe.andThen (targetWorldScores worlds)
                    |> Maybe.andThen (getScoreFor tileType)

            prev =
                progress.current
                    |> Maybe.map (Levels.previous worlds >> scoresAtLevel worlds)
                    |> Maybe.andThen (getScoreFor tileType)
        in
        Maybe.map2 (-) curr prev

    else if atFirst progress then
        progress.current
            |> Maybe.map (Levels.next worlds >> scoresAtLevel worlds)
            |> Maybe.andThen (getScoreFor tileType)

    else
        let
            curr =
                scoresAtLevel worlds progress.reached
                    |> getScoreFor tileType

            prev =
                scoresAtLevel worlds (Levels.previous worlds progress.reached)
                    |> getScoreFor tileType
        in
        Maybe.map2 (-) curr prev



-- Internal


withLevelOffset : Levels.Worlds -> ProgressState -> Levels.Key
withLevelOffset worlds rawProgress =
    if atFinalLevelOfWorld worlds rawProgress then
        Levels.previous worlds rawProgress.reached

    else
        rawProgress.reached


atFinalLevelOfWorld : Levels.Worlds -> ProgressState -> Bool
atFinalLevelOfWorld worlds { current, reached } =
    Levels.isFirstLevelOfWorld reached
        && (Maybe.map (Levels.isLastLevelOfWorld worlds) current |> Maybe.withDefault False)


atFirstLevelOfWorld : ProgressState -> Bool
atFirstLevelOfWorld { current, reached } =
    Levels.isFirstLevelOfWorld reached
        && (Maybe.map Levels.isFirstLevelOfWorld current |> Maybe.withDefault False)


atFirst : ProgressState -> Bool
atFirst { current } =
    Maybe.map Levels.isFirstLevelOfWorld current |> Maybe.withDefault False



-- Scores


getScoreFor : TileType -> Dict String Int -> Maybe Int
getScoreFor =
    Tile.hash >> Dict.get


resourcesInLevels : SeedType -> List Levels.Level -> List TileType
resourcesInLevels worldSeedType =
    List.map tileSettings
        >> List.concat
        >> List.filter Score.collectable
        >> List.map .tileType
        >> List.filter (secondaryResource worldSeedType)
        >> Helpers.List.unique


scoresAtLevel : Levels.Worlds -> Levels.Key -> Dict String Int
scoresAtLevel worlds level =
    level
        |> Levels.getKeysForWorld worlds
        |> Maybe.withDefault []
        |> List.filter (Levels.completed level)
        |> List.map (Levels.getLevel worlds >> Maybe.map tileSettings >> Maybe.withDefault [])
        |> List.concat
        |> totalScoresDict
        |> combineWithEmptyScores worlds level


combineWithEmptyScores : Levels.Worlds -> Levels.Key -> Dict String Int -> Dict String Int
combineWithEmptyScores worlds levels scores =
    scoresAtBeginningOfWorld worlds levels
        |> Maybe.withDefault Dict.empty
        |> Dict.union scores


scoresAtBeginningOfWorld : Levels.Worlds -> Levels.Key -> Maybe (Dict String Int)
scoresAtBeginningOfWorld worlds level =
    targetWorldScores worlds level
        |> Maybe.map (Helpers.Dict.mapValues <| always 0)


targetWorldScores : Levels.Worlds -> Levels.Key -> Maybe (Dict String Int)
targetWorldScores worlds level =
    level
        |> Levels.getLevels worlds
        |> Maybe.map scoresForWorld


scoresForWorld : List Levels.Level -> Dict String Int
scoresForWorld levels =
    levels
        |> List.map tileSettings
        |> List.concat
        |> totalScoresDict


totalScoresDict : List TileSetting -> Dict String Int
totalScoresDict =
    List.foldr accumSettings Dict.empty


accumSettings : TileSetting -> Dict String Int -> Dict String Int
accumSettings setting acc =
    case setting.targetScore of
        Just (TargetScore n) ->
            Helpers.Dict.insertWith (+) (Tile.hash setting.tileType) n acc

        Nothing ->
            acc


secondaryResource : SeedType -> TileType -> Bool
secondaryResource worldSeedType tileType =
    case Tile.getSeedType tileType of
        Just seed ->
            not <| worldSeedType == seed

        Nothing ->
            True


tileSettings : Levels.Level -> List TileSetting
tileSettings =
    Levels.config >> .tiles
