module Level.Progress exposing
    ( Progress
    , clearCurrentLevel
    , currentLevel
    , currentLevelComplete
    , currentLevelSeedType
    , currentWorldComplete
    , fromCache
    , handleIncrement
    , percentComplete
    , pointsFromPreviousLevel
    , reachedLevel
    , reachedLevelSeedType
    , resources
    , setCurrentLevel
    , toCache
    )

import Board.Scores as Score
import Board.Tile as Tile
import Config.Levels as Levels
import Dict exposing (Dict)
import Level.Setting.Tile as Tile exposing (TargetScore(..))
import Utils.Dict
import Utils.List


type Progress
    = Progress State


type alias State =
    { current : Maybe Levels.Id
    , reached : Levels.Id
    }


type Position
    = CurrentWorldComplete
    | FirstLevelOfWorld
    | MiddleLevel



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


fromLevel : Levels.Id -> Progress
fromLevel reached =
    Progress
        { current = Nothing
        , reached = reached
        }



-- Update


setCurrentLevel : Levels.Id -> Progress -> Progress
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


reachedLevel : Progress -> Levels.Id
reachedLevel (Progress progress) =
    progress.reached


currentLevel : Progress -> Maybe Levels.Id
currentLevel (Progress progress) =
    progress.current


currentWorldComplete : Levels.Worlds -> Progress -> Bool
currentWorldComplete worlds (Progress { current, reached }) =
    current
        |> Maybe.map (\level -> Levels.isLastLevelOfWorld worlds level && Levels.isFirstLevelOfWorld reached)
        |> Maybe.withDefault False


currentLevelComplete : Progress -> Maybe Bool
currentLevelComplete (Progress { current, reached }) =
    Maybe.map (\level -> Levels.completed reached level) current


reachedLevelSeedType : Levels.Worlds -> Progress -> Maybe Tile.SeedType
reachedLevelSeedType worlds (Progress progress) =
    Levels.seedType worlds progress.reached


currentLevelSeedType : Levels.Worlds -> Progress -> Maybe Tile.SeedType
currentLevelSeedType worlds (Progress progress) =
    Maybe.andThen (Levels.seedType worlds) progress.current


resources : Levels.Worlds -> Progress -> Maybe (List Tile.Type)
resources worlds (Progress progress) =
    case progress.current of
        Just level ->
            Maybe.map2
                resourcesInLevels
                (Levels.seedType worlds level)
                (Levels.getLevels worlds level)

        Nothing ->
            Nothing


percentComplete : Levels.Worlds -> Tile.Type -> Progress -> Maybe Float
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


pointsFromPreviousLevel : Levels.Worlds -> Tile.Type -> Progress -> Maybe Int
pointsFromPreviousLevel worlds tileType ((Progress { reached, current }) as progress) =
    let
        tileScore =
            getScoreFor tileType

        levelScores =
            scoresAtLevel worlds

        previous =
            Levels.previous worlds
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
                |> Maybe.map (Levels.next worlds >> levelScores)
                |> Maybe.andThen tileScore

        MiddleLevel ->
            Maybe.map2 (-)
                (tileScore <| levelScores reached)
                (tileScore <| levelScores <| previous reached)



-- Internal


position : Levels.Worlds -> Progress -> Position
position worlds ((Progress { current }) as progress) =
    if currentWorldComplete worlds progress then
        CurrentWorldComplete

    else if Maybe.map Levels.isFirstLevelOfWorld current == Just True then
        FirstLevelOfWorld

    else
        MiddleLevel


getScoreFor : Tile.Type -> Dict String Int -> Maybe Int
getScoreFor =
    Tile.hash >> Dict.get


resourcesInLevels : Tile.SeedType -> List Levels.Level -> List Tile.Type
resourcesInLevels worldSeedType =
    List.map tileSettings
        >> List.concat
        >> List.filter Score.collectible
        >> List.map .tileType
        >> List.filter (secondaryResource worldSeedType)
        >> Utils.List.unique


scoresAtLevel : Levels.Worlds -> Levels.Id -> Dict String Int
scoresAtLevel worlds level =
    level
        |> Levels.idsForWorld worlds
        |> Maybe.withDefault []
        |> List.filter (Levels.completed level)
        |> List.map (Levels.getLevel worlds >> Maybe.map tileSettings >> Maybe.withDefault [])
        |> List.concat
        |> totalScoresDict
        |> combineWithEmptyScores worlds level


combineWithEmptyScores : Levels.Worlds -> Levels.Id -> Dict String Int -> Dict String Int
combineWithEmptyScores worlds levels scores =
    scoresAtBeginningOfWorld worlds levels
        |> Maybe.withDefault Dict.empty
        |> Dict.union scores


scoresAtBeginningOfWorld : Levels.Worlds -> Levels.Id -> Maybe (Dict String Int)
scoresAtBeginningOfWorld worlds level =
    targetWorldScores worlds level
        |> Maybe.map (Utils.Dict.mapValues <| always 0)


targetWorldScores : Levels.Worlds -> Levels.Id -> Maybe (Dict String Int)
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


totalScoresDict : List Tile.Setting -> Dict String Int
totalScoresDict =
    List.foldr accumSettings Dict.empty


accumSettings : Tile.Setting -> Dict String Int -> Dict String Int
accumSettings setting acc =
    case setting.targetScore of
        Just (TargetScore n) ->
            Utils.Dict.insertWith (+) (Tile.hash setting.tileType) n acc

        Nothing ->
            acc


secondaryResource : Tile.SeedType -> Tile.Type -> Bool
secondaryResource worldSeedType tileType =
    case Tile.getSeedType tileType of
        Just seed ->
            not <| worldSeedType == seed

        Nothing ->
            True


tileSettings : Levels.Level -> List Tile.Setting
tileSettings =
    Levels.config >> .tileSettings
