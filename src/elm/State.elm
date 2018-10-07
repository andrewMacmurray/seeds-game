module State exposing
    ( addTimeTillNextLife
    , backToHubSequence
    , countDownToNextLife
    , currentLevel
    , decrementAboveZero
    , decrementLives
    , fromProgress
    , handleCacheTimes
    , handleHubMsg
    , handleIncrementProgress
    , handleIntroMsg
    , handleLevelMsg
    , handleTutorialMsg
    , init
    , initLastPlayed
    , initProgressFromCache
    , initTimeTillNextLife
    , initialState
    , levelCompleteScrollNumber
    , levelLoseSequence
    , levelWinSequence
    , livesLeft
    , loadHub
    , loadIntro
    , loadLevel
    , loadRetry
    , loadSummary
    , loadTutorial
    , progressLevelNumber
    , sceneSubscriptions
    , subscribeDecrement
    , subscriptions
    , tutorialData
    , update
    , updateTimes
    )

import Browser.Events
import Config.Levels exposing (..)
import Config.Scale as ScaleConfig
import Config.Text exposing (randomSuccessMessageIndex)
import Data.Background exposing (..)
import Data.InfoWindow as InfoWindow
import Data.Level.Progress exposing (..)
import Data.Level.Types exposing (..)
import Data.Transit as Transit exposing (Transit(..))
import Data.Visibility exposing (Visibility(..))
import Data.Window as Window
import Exit
import Helpers.Delay exposing (..)
import Ports exposing (..)
import Scenes.Hub.State as Hub
import Scenes.Hub.Types exposing (HubModel, HubMsg(..))
import Scenes.Intro.State as Intro
import Scenes.Intro.Types exposing (IntroModel, IntroMsg)
import Scenes.Level.State as Level
import Scenes.Level.Types exposing (LevelModel, LevelMsg, LevelStatus(..))
import Scenes.Tutorial.State as Tutorial
import Scenes.Tutorial.Types exposing (TutorialConfig, TutorialModel, TutorialMsg)
import Task
import Time exposing (posixToMillis)
import Types exposing (..)



-- Init


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( initialState flags
    , Cmd.batch
        [ generateBounceKeyframes ScaleConfig.baseTileSizeY
        , randomSuccessMessageIndex GenerateSuccessMessageIndex
        ]
    )


initialState : Flags -> Model
initialState flags =
    { scene = Title
    , loadingScreen = Nothing
    , progress = initProgressFromCache flags.rawProgress
    , currentLevel = Nothing
    , window = flags.window
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
            ( { model | successMessageIndex = i }
            , Cmd.none
            )

        IncrementSuccessMessageIndex ->
            ( { model | successMessageIndex = model.successMessageIndex + 1 }
            , Cmd.none
            )

        StartLevel level ->
            case tutorialData level of
                Just tutorialConfig ->
                    ( model
                    , sequence
                        [ ( 600, SetCurrentLevel <| Just level )
                        , ( 10, ShowLoadingScreen )
                        , ( 2500, LoadTutorial level tutorialConfig )
                        , ( 500, HideLoadingScreen )
                        ]
                    )

                Nothing ->
                    ( model
                    , sequence
                        [ ( 600, SetCurrentLevel <| Just level )
                        , ( 10, ShowLoadingScreen )
                        , ( 1000, LoadLevel level )
                        , ( 2000, HideLoadingScreen )
                        ]
                    )

        RestartLevel ->
            ( model
            , sequence
                [ ( 10, ShowLoadingScreen )
                , ( 600, LoadLevel <| currentLevel model )
                , ( 2500, HideLoadingScreen )
                ]
            )

        LoadTutorial level config ->
            loadTutorial model (getLevelData level) config

        LoadLevel level ->
            loadLevel model level

        LoadIntro ->
            loadIntro model

        LoadHub levelNumber ->
            loadHub levelNumber model

        LoadSummary ->
            ( loadSummary model
            , Cmd.none
            )

        LoadRetry ->
            ( loadRetry model
            , Cmd.none
            )

        FadeTitle ->
            ( { model | titleAnimation = Leaving }
            , Cmd.none
            )

        LevelWin ->
            ( model
            , sequence <| levelWinSequence model
            )

        LevelLose ->
            ( model
            , sequence <| levelLoseSequence model
            )

        ShowLoadingScreen ->
            ( model
            , genRandomBackground RandomBackground
            )

        RandomBackground background ->
            ( { model | loadingScreen = Just background }
            , Cmd.none
            )

        HideLoadingScreen ->
            ( { model | loadingScreen = Nothing }
            , Cmd.none
            )

        SetCurrentLevel progress ->
            ( { model | currentLevel = progress }
            , Cmd.none
            )

        GoToHub ->
            ( model
            , sequence
                [ ( 0, ShowLoadingScreen )
                , ( 1000, LoadHub <| progressLevelNumber model )
                , ( 2000, HideLoadingScreen )
                ]
            )

        GoToIntro ->
            ( model
            , playIntroMusic ()
            )

        IntroMusicPlaying playing ->
            ( model
            , sequence
                [ ( 0, FadeTitle )
                , ( 2000, LoadIntro )
                ]
            )

        ClearCache ->
            ( model
            , clearCache
            )

        WindowSize width height ->
            ( { model | window = Window.Size width height }
            , generateBounceKeyframes <| ScaleConfig.baseTileSizeY * ScaleConfig.tileScaleFactor (Window.Size width height)
            )

        UpdateTimes now ->
            updateTimes (toFloat (posixToMillis now)) model

        -- Summary and Retry
        IncrementProgress ->
            handleIncrementProgress model

        DecrementLives ->
            ( addTimeTillNextLife model
            , Cmd.none
            )



-- Scene Loaders


loadLevel : Model -> Progress -> ( Model, Cmd Msg )
loadLevel model level =
    Level.init model.successMessageIndex (getLevelData level)
        |> stepLevel model


stepLevel : Model -> ( LevelModel, Cmd LevelMsg ) -> ( Model, Cmd Msg )
stepLevel model ( levelModel, levelCmd ) =
    ( { model | scene = Level levelModel }
    , Cmd.map LevelMsg levelCmd
    )


loadTutorial : Model -> LevelData TutorialConfig -> TutorialConfig -> ( Model, Cmd Msg )
loadTutorial model levelData config =
    Tutorial.init model.successMessageIndex levelData config
        |> stepTutorial model


stepTutorial : Model -> ( TutorialModel, Cmd TutorialMsg ) -> ( Model, Cmd Msg )
stepTutorial model ( tutorialModel, tutorialCmd ) =
    ( { model | scene = Tutorial tutorialModel }
    , Cmd.map TutorialMsg tutorialCmd
    )


loadIntro : Model -> ( Model, Cmd Msg )
loadIntro model =
    Intro.init |> stepIntro model


stepIntro : Model -> ( IntroModel, Cmd IntroMsg ) -> ( Model, Cmd Msg )
stepIntro model ( introModel, introCmd ) =
    ( { model | scene = Intro introModel }
    , Cmd.map IntroMsg introCmd
    )


loadHub : Int -> Model -> ( Model, Cmd Msg )
loadHub levelNumber model =
    Hub.init levelNumber model |> stepHub model


stepHub : Model -> ( HubModel model, Cmd HubMsg ) -> ( Model, Cmd Msg )
stepHub model ( hubModel, hubCmd ) =
    ( { model | scene = Hub }
    , Cmd.map HubMsg hubCmd
    )


loadSummary : Model -> Model
loadSummary model =
    case model.scene of
        Level levelModel ->
            -- FIXME need to load backdrop
            { model | scene = Summary }

        _ ->
            model


loadRetry : Model -> Model
loadRetry model =
    case model.scene of
        Level levelModel ->
            -- FIXME need to load backdrop
            { model | scene = Retry }

        _ ->
            model



-- Scene updaters


handleLevelMsg : LevelMsg -> Model -> ( Model, Cmd Msg )
handleLevelMsg levelMsg model =
    case model.scene of
        Level levelModel ->
            Exit.handle
                { state = Level.update levelMsg levelModel
                , onContinue = stepLevel model
                , onExit = exitLevel model
                }

        _ ->
            ( model
            , Cmd.none
            )


exitLevel : Model -> LevelStatus -> ( Model, Cmd Msg )
exitLevel model levelStatus =
    let
        exitLevelCmd =
            case levelStatus of
                Win ->
                    trigger LevelWin

                Lose ->
                    trigger LevelLose

                _ ->
                    Cmd.none
    in
    ( model, exitLevelCmd )


handleTutorialMsg : TutorialMsg -> Model -> ( Model, Cmd Msg )
handleTutorialMsg tutorialMsg model =
    case model.scene of
        Tutorial tutorialModel ->
            Exit.handle
                { state = Tutorial.update tutorialMsg tutorialModel
                , onContinue = stepTutorial model

                -- FIXME need to load level
                , onExit = always ( model, Cmd.none )
                }

        _ ->
            ( model
            , Cmd.none
            )


handleHubMsg : HubMsg -> Model -> ( Model, Cmd Msg )
handleHubMsg hubMsg model =
    let
        ( newModel, cmd ) =
            Hub.update hubMsg model
    in
    ( newModel
    , Cmd.map HubMsg cmd
    )


handleIntroMsg : IntroMsg -> Model -> ( Model, Cmd Msg )
handleIntroMsg introMsg model =
    case model.scene of
        Intro introModel ->
            Exit.handle
                { state = Intro.update introMsg introModel
                , onContinue = stepIntro model
                , onExit = always ( model, Cmd.batch [ trigger GoToHub, fadeMusic () ] )
                }

        _ ->
            ( model
            , Cmd.none
            )



-- Misc


initProgressFromCache : Maybe RawProgress -> Progress
initProgressFromCache rawProgress =
    rawProgress
        |> Maybe.map (\{ world, level } -> ( world, level ))
        |> Maybe.withDefault ( 1, 1 )


fromProgress : Progress -> RawProgress
fromProgress ( world, level ) =
    RawProgress world level


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
    ( { model | progress = progress }
    , cacheProgress <| fromProgress progress
    )


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


initLastPlayed : Flags -> Float
initLastPlayed flags =
    flags.times
        |> Maybe.map .lastPlayed
        |> Maybe.withDefault flags.now


initTimeTillNextLife : Flags -> Float
initTimeTillNextLife flags =
    flags.times
        |> Maybe.map (\t -> decrementAboveZero (flags.now - t.lastPlayed) t.timeTillNextLife)
        |> Maybe.withDefault 0


updateTimes : Float -> Model -> ( Model, Cmd Msg )
updateTimes now model =
    let
        newModel =
            countDownToNextLife now model
    in
    ( newModel
    , handleCacheTimes newModel
    )


handleCacheTimes : Model -> Cmd msg
handleCacheTimes model =
    cacheTimes
        { timeTillNextLife = model.timeTillNextLife
        , lastPlayed = model.lastPlayed
        }


countDownToNextLife : Float -> Model -> Model
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


livesLeft : Float -> Float
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
        [ Browser.Events.onResize WindowSize
        , introMusicPlaying IntroMusicPlaying
        , subscribeDecrement model
        , sceneSubscriptions model
        ]


subscribeDecrement : Model -> Sub Msg
subscribeDecrement model =
    if model.scene == Hub && model.timeTillNextLife > 0 then
        Time.every 100 UpdateTimes

    else
        Time.every (10 * 1000) UpdateTimes


sceneSubscriptions : Model -> Sub Msg
sceneSubscriptions model =
    case model.scene of
        Level levelModel ->
            Sub.map LevelMsg <| Level.subscriptions levelModel

        Tutorial tutorialModel ->
            Sub.map TutorialMsg <| Tutorial.subscriptions tutorialModel

        Intro introModel ->
            Sub.map IntroMsg <| Intro.subscriptions introModel

        _ ->
            Sub.none
