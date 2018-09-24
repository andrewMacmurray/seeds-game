module State exposing (..)

import Config.Levels exposing (..)
import Config.Scale as ScaleConfig
import Config.Text exposing (randomSuccessMessageIndex)
import Data.Background exposing (..)
import Data.InfoWindow as InfoWindow
import Data.Level.Progress exposing (..)
import Data.Level.Types exposing (..)
import Data.Transit as Transit exposing (Transit(..))
import Data.Visibility exposing (Visibility(..))
import Helpers.Delay exposing (..)
import Helpers.Exit exposing (ExitMsg(..), loadScene, mapScene, onExit, onExitDo)
import Ports exposing (..)
import Scenes.Hub.State as Hub
import Scenes.Hub.Types exposing (HubMsg(..))
import Scenes.Intro.State as Intro
import Scenes.Intro.Types exposing (IntroMsg)
import Scenes.Level.State as Level
import Scenes.Level.Types exposing (LevelMsg, LevelStatus(..))
import Scenes.Tutorial.State as Tutorial
import Scenes.Tutorial.Types exposing (TutorialConfig, TutorialMsg)
import Task
import Time exposing (Time, every, millisecond, second)
import Types exposing (..)
import Window exposing (resizes, size)



-- Init


init : Flags -> ( Model, Cmd Msg )
init flags =
    initialState flags
        ! [ Task.perform WindowSize size
          , generateBounceKeyframes ScaleConfig.baseTileSizeY
          , randomSuccessMessageIndex GenerateSuccessMessageIndex
          ]


initialState : Flags -> Model
initialState flags =
    { scene = Loaded Title
    , loadingScreen = Nothing
    , progress = initProgressFromCache flags.rawProgress
    , currentLevel = Just ( 2, 2 )
    , window = { height = 0, width = 0 }
    , lastPlayed = initLastPlayed flags
    , timeTillNextLife = initTimeTillNextLife flags
    , titleAnimation = Entering
    , hubInfoWindow = InfoWindow.hidden
    , successMessageIndex = 0
    }



-- Update


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LevelMsg levelMsg ->
            handleLevelMsg levelMsg model

        TutorialMsg tutorialMsg ->
            handleTutorialMsg tutorialMsg model

        HubMsg hubMsg ->
            handleHubMsg hubMsg model

        IntroMsg introMsg ->
            handleIntroMsg introMsg model

        GenerateSuccessMessageIndex i ->
            { model | successMessageIndex = i } ! []

        IncrementSuccessMessageIndex ->
            { model | successMessageIndex = model.successMessageIndex + 1 } ! []

        StartLevel level ->
            case tutorialData level of
                Just tutorialConfig ->
                    model
                        ! [ sequenceMs
                                [ ( 600, SetCurrentLevel <| Just level )
                                , ( 10, ShowLoadingScreen )
                                , ( 2500, LoadTutorial level tutorialConfig )
                                , ( 500, HideLoadingScreen )
                                ]
                          ]

                Nothing ->
                    model
                        ! [ sequenceMs
                                [ ( 600, SetCurrentLevel <| Just level )
                                , ( 10, ShowLoadingScreen )
                                , ( 1000, LoadLevel level )
                                , ( 2000, HideLoadingScreen )
                                ]
                          ]

        RestartLevel ->
            model
                ! [ sequenceMs
                        [ ( 10, ShowLoadingScreen )
                        , ( 600, LoadLevel <| currentLevel model )
                        , ( 2500, HideLoadingScreen )
                        ]
                  ]

        LoadTutorial level config ->
            loadTutorial model (getLevelData level) config

        LoadLevel level ->
            loadLevel model level

        LoadIntro ->
            loadIntro model

        LoadHub levelNumber ->
            loadHub levelNumber model

        LoadSummary ->
            loadSummary model ! [ delayMs 1000 CompleteSceneTransition ]

        LoadRetry ->
            loadRetry model ! [ delayMs 1000 CompleteSceneTransition ]

        FadeTitle ->
            { model | titleAnimation = Leaving } ! []

        CompleteSceneTransition ->
            { model | scene = completeSceneTransition model.scene } ! []

        LevelWin ->
            model ! [ sequenceMs <| levelWinSequence model ]

        LevelLose ->
            model ! [ sequenceMs <| levelLoseSequence model ]

        ShowLoadingScreen ->
            model ! [ genRandomBackground RandomBackground ]

        RandomBackground background ->
            { model | loadingScreen = Just background } ! []

        HideLoadingScreen ->
            { model | loadingScreen = Nothing } ! []

        SetCurrentLevel progress ->
            { model | currentLevel = progress } ! []

        GoToHub ->
            model
                ! [ sequenceMs
                        [ ( 0, ShowLoadingScreen )
                        , ( 1000, LoadHub <| progressLevelNumber model )
                        , ( 2000, HideLoadingScreen )
                        ]
                  ]

        GoToIntro ->
            model ! [ playIntroMusic () ]

        IntroMusicPlaying playing ->
            model
                ! [ sequenceMs
                        [ ( 0, FadeTitle )
                        , ( 2000, LoadIntro )
                        ]
                  ]

        ClearCache ->
            model ! [ clearCache ]

        WindowSize size ->
            { model | window = size }
                ! [ generateBounceKeyframes <| ScaleConfig.baseTileSizeY * ScaleConfig.tileScaleFactor size ]

        UpdateTimes now ->
            updateTimes now model

        -- Summary and Retry
        IncrementProgress ->
            handleIncrementProgress model

        DecrementLives ->
            addTimeTillNextLife model ! []



-- Scene Loaders


loadLevel : Model -> Progress -> ( Model, Cmd Msg )
loadLevel model level =
    Level.init model.successMessageIndex (getLevelData level)
        |> loadScene Level LevelMsg model


loadTutorial : Model -> LevelData TutorialConfig -> TutorialConfig -> ( Model, Cmd Msg )
loadTutorial model levelData config =
    Tutorial.init model.successMessageIndex levelData config
        |> loadScene Tutorial TutorialMsg model


loadIntro : Model -> ( Model, Cmd Msg )
loadIntro model =
    Intro.init |> loadScene Intro IntroMsg model


loadHub : Int -> Model -> ( Model, Cmd Msg )
loadHub levelNumber model =
    Hub.init levelNumber model |> loadScene (always Hub) HubMsg model


loadSummary : Model -> Model
loadSummary model =
    case model.scene of
        Loaded (Level levelModel) ->
            { model | scene = Transition { from = Level levelModel, to = Summary } }

        _ ->
            model


loadRetry : Model -> Model
loadRetry model =
    case model.scene of
        Loaded (Level levelModel) ->
            { model | scene = Transition { from = Level levelModel, to = Retry } }

        _ ->
            model


completeSceneTransition : SceneState -> SceneState
completeSceneTransition sceneState =
    case sceneState of
        Transition { to } ->
            Loaded to

        _ ->
            sceneState



-- Scene updaters


handleLevelMsg : LevelMsg -> Model -> ( Model, Cmd Msg )
handleLevelMsg levelMsg model =
    case model.scene of
        Loaded (Level levelModel) ->
            Level.update levelMsg levelModel
                |> mapScene model Level LevelMsg
                |> onExitLevel

        _ ->
            model ! []


onExitLevel : ( Model, Cmd Msg, ExitMsg LevelStatus ) -> ( Model, Cmd Msg )
onExitLevel (( _, _, levelStatus ) as out) =
    let
        exitLevelCmd =
            case levelStatus of
                ExitWith Win ->
                    trigger LevelWin

                ExitWith Lose ->
                    trigger LevelLose

                _ ->
                    Cmd.none
    in
    onExitDo [ exitLevelCmd ] out


handleTutorialMsg : TutorialMsg -> Model -> ( Model, Cmd Msg )
handleTutorialMsg tutorialMsg model =
    case model.scene of
        Loaded (Tutorial tutorialModel) ->
            Tutorial.update tutorialMsg tutorialModel
                |> mapScene model Tutorial TutorialMsg
                |> onExit (\model -> { model | scene = tutorialToLevel model.scene }) []

        _ ->
            model ! []


tutorialToLevel : SceneState -> SceneState
tutorialToLevel scene =
    case scene of
        Loaded (Tutorial tutorialModel) ->
            Loaded (Level tutorialModel.levelModel)

        _ ->
            scene


handleHubMsg : HubMsg -> Model -> ( Model, Cmd Msg )
handleHubMsg hubMsg model =
    let
        ( newModel, cmd ) =
            Hub.update hubMsg model
    in
    newModel ! [ Cmd.map HubMsg cmd ]


handleIntroMsg : IntroMsg -> Model -> ( Model, Cmd Msg )
handleIntroMsg introMsg model =
    case model.scene of
        Loaded (Intro introModel) ->
            Intro.update introMsg introModel
                |> mapScene model Intro IntroMsg
                |> onExitDo [ trigger GoToHub, fadeMusic () ]

        _ ->
            model ! []



-- Misc


initProgressFromCache : Maybe RawProgress -> Progress
initProgressFromCache rawProgress =
    rawProgress
        |> Maybe.map (\{ world, level } -> ( world, level ))
        |> Maybe.withDefault ( 1, 1 )


fromProgress : Progress -> RawProgress
fromProgress ( world, level ) =
    RawProgress world level


getLevelData : Progress -> LevelData TutorialConfig
getLevelData =
    levelData allLevels >> Maybe.withDefault defaultLevel


getLevelConfig : Progress -> CurrentLevelConfig TutorialConfig
getLevelConfig =
    levelConfig allLevels >> Maybe.withDefault ( defaultWorld, defaultLevel )


tutorialData : Progress -> Maybe TutorialConfig
tutorialData level =
    let
        ( _, levelData ) =
            getLevelConfig level
    in
    levelData.tutorial


handleIncrementProgress : Model -> ( Model, Cmd Msg )
handleIncrementProgress model =
    let
        progress =
            incrementProgress allLevels model.currentLevel model.progress
    in
    { model | progress = progress } ! [ cacheProgress <| fromProgress progress ]


progressLevelNumber : Model -> Int
progressLevelNumber model =
    getLevelNumber model.progress allLevels


levelWinSequence : Model -> List ( Float, Msg )
levelWinSequence model =
    let
        backToHub =
            backToHubSequence <| levelCompleteScrollNumber model
    in
    if shouldIncrement allLevels model.currentLevel model.progress then
        [ ( 0, LoadSummary )
        , ( 2000, IncrementProgress )
        , ( 2500, ShowLoadingScreen )
        , ( 0, IncrementSuccessMessageIndex )
        ]
            ++ backToHub

    else
        ( 0, ShowLoadingScreen ) :: backToHub


levelLoseSequence : Model -> List ( Float, Msg )
levelLoseSequence model =
    [ ( 0, LoadRetry )
    , ( 1000, DecrementLives )
    ]


backToHubSequence : Int -> List ( Float, Msg )
backToHubSequence levelNumber =
    [ ( 1000, LoadHub levelNumber )
    , ( 1500, HideLoadingScreen )
    , ( 500, SetCurrentLevel Nothing )
    ]


levelCompleteScrollNumber : Model -> Int
levelCompleteScrollNumber model =
    if shouldIncrement allLevels model.currentLevel model.progress then
        progressLevelNumber model + 1

    else
        getLevelNumber (Maybe.withDefault ( 1, 1 ) model.currentLevel) allLevels



-- Life Timers


initLastPlayed : Flags -> Time
initLastPlayed flags =
    flags.times
        |> Maybe.map .lastPlayed
        |> Maybe.withDefault flags.now


initTimeTillNextLife : Flags -> Time
initTimeTillNextLife flags =
    flags.times
        |> Maybe.map (\t -> decrementAboveZero (flags.now - t.lastPlayed) t.timeTillNextLife)
        |> Maybe.withDefault 0


updateTimes : Time -> Model -> ( Model, Cmd Msg )
updateTimes now model =
    let
        newModel =
            countDownToNextLife now model
    in
    newModel ! [ handleCacheTimes newModel ]


handleCacheTimes : Model -> Cmd msg
handleCacheTimes model =
    cacheTimes
        { timeTillNextLife = model.timeTillNextLife
        , lastPlayed = model.lastPlayed
        }


countDownToNextLife : Time -> Model -> Model
countDownToNextLife now model =
    if model.timeTillNextLife <= 0 then
        { model | lastPlayed = now }

    else
        let
            newTimeTillNextLife =
                decrementAboveZero (now - model.lastPlayed) model.timeTillNextLife

            lifeVal =
                floor <| livesLeft newTimeTillNextLife
        in
        { model
            | timeTillNextLife = newTimeTillNextLife
            , lastPlayed = now
        }


currentLevel : Model -> Progress
currentLevel model =
    model.currentLevel |> Maybe.withDefault ( 1, 1 )


livesLeft : Time -> Float
livesLeft timeTill =
    (timeTill - (lifeRecoveryInterval * maxLives)) / -lifeRecoveryInterval


addTimeTillNextLife : Model -> Model
addTimeTillNextLife model =
    { model | timeTillNextLife = model.timeTillNextLife + lifeRecoveryInterval }


decrementLives : Transit Int -> Transit Int
decrementLives lifeState =
    lifeState
        |> Transit.map (decrementAboveZero 1)
        |> Transit.toTransitioning


decrementAboveZero : number -> number -> number
decrementAboveZero x n =
    clamp 0 100000000000 (n - x)



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ resizes WindowSize
        , introMusicPlaying IntroMusicPlaying
        , subscribeDecrement model
        , sceneSubscriptions model
        ]


subscribeDecrement : Model -> Sub Msg
subscribeDecrement model =
    if model.scene == Loaded Hub && model.timeTillNextLife > 0 then
        every (millisecond * 100) UpdateTimes

    else
        every (second * 10) UpdateTimes


sceneSubscriptions : Model -> Sub Msg
sceneSubscriptions model =
    case model.scene of
        Loaded (Level levelModel) ->
            Sub.map LevelMsg <| Level.subscriptions levelModel

        Loaded (Tutorial tutorialModel) ->
            Sub.map TutorialMsg <| Tutorial.subscriptions tutorialModel

        Loaded Hub ->
            Sub.map HubMsg <| Hub.subscriptions model

        Loaded (Intro introModel) ->
            Sub.map IntroMsg <| Intro.subscriptions introModel

        _ ->
            Sub.none
