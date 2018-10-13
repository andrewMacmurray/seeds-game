module State exposing
    ( init
    , subscriptions
    , update
    )

import Browser.Events
import Config.Levels exposing (..)
import Config.Scale as ScaleConfig
import Data.Background exposing (..)
import Data.InfoWindow as InfoWindow
import Data.Level.Types exposing (..)
import Data.Transit as Transit exposing (Transit(..))
import Data.Visibility exposing (Visibility(..))
import Data.Window as Window
import Exit
import Helpers.Delay exposing (..)
import Ports exposing (..)
import Scene exposing (Scene(..))
import Scenes.Hub as Hub
import Scenes.Intro as Intro
import Scenes.Level as Level
import Scenes.Title as Title
import Scenes.Tutorial.State as Tutorial
import Scenes.Tutorial.Types exposing (TutorialConfig, TutorialModel, TutorialMsg)
import Shared exposing (..)
import Task
import Time exposing (posixToMillis)
import Types exposing (..)



-- Init


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( initialState flags
    , bounceKeyframes flags.window
    )


initialState : Flags -> Model
initialState flags =
    { scene = Title <| Title.init <| initShared flags
    }


initShared : Flags -> Shared.Data
initShared flags =
    { window = flags.window
    , loadingScreen = Nothing
    , progress = initProgressFromCache flags.rawProgress
    , currentLevel = Nothing
    , successMessageIndex = flags.randomMessageIndex
    }



-- Update


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TitleMsg titleMsg ->
            handleTitleMsg titleMsg model

        LevelMsg levelMsg ->
            handleLevelMsg levelMsg model

        TutorialMsg tutorialMsg ->
            handleTutorialMsg tutorialMsg model

        HubMsg hubMsg ->
            handleHubMsg hubMsg model

        IntroMsg introMsg ->
            handleIntroMsg introMsg model

        IncrementSuccessMessageIndex ->
            ( { model | scene = Scene.map incrementMessageIndex model.scene }, Cmd.none )

        StartLevel level ->
            case tutorialData level of
                Just tutorialConfig ->
                    ( model
                    , sequence
                        [ ( 600, SetCurrentLevel <| Just level )
                        , ( 10, ShowLoadingScreen )
                        , ( 2500, LoadTutorial tutorialConfig )
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
            ( model, withLoadingScreen <| LoadLevel <| currentLevel model )

        LoadTutorial config ->
            loadTutorial config model

        LoadLevel level ->
            loadLevel level model

        LoadIntro ->
            loadIntro model

        LoadHub levelNumber ->
            loadHub levelNumber model

        LoadSummary ->
            ( loadSummary model, Cmd.none )

        LoadRetry ->
            ( loadRetry model, Cmd.none )

        LevelWin ->
            ( model, sequence <| levelWinSequence model )

        LevelLose ->
            ( model, sequence <| levelLoseSequence model )

        ShowLoadingScreen ->
            ( model, genRandomBackground RandomBackground )

        RandomBackground background ->
            ( { model | scene = Scene.map (showLoadingScreen background) model.scene }, Cmd.none )

        HideLoadingScreen ->
            ( { model | scene = Scene.map hideLoadingScreen model.scene }, Cmd.none )

        SetCurrentLevel progress ->
            ( { model | scene = Scene.map (setCurrentLevel progress) model.scene }, Cmd.none )

        GoToHub ->
            ( model, withLoadingScreen <| LoadHub <| progressLevelNumber model )

        ClearCache ->
            ( model, clearCache )

        WindowSize width height ->
            ( { model | scene = Scene.map (setWindow width height) model.scene }
            , bounceKeyframes <| Window.Size width height
            )

        UpdateTimes now ->
            updateTimes (toFloat (posixToMillis now)) model

        -- Summary and Retry
        IncrementProgress ->
            handleIncrementProgress model

        DecrementLives ->
            ( addTimeTillNextLife model, Cmd.none )


withLoadingScreen : Msg -> Cmd Msg
withLoadingScreen =
    sequence << loadingSequence


loadingSequence : Msg -> List ( Float, Msg )
loadingSequence msg =
    [ ( 0, ShowLoadingScreen )
    , ( 1000, msg )
    , ( 2000, HideLoadingScreen )
    ]



-- Scene Loaders


loadLevel : Progress -> Model -> ( Model, Cmd Msg )
loadLevel level =
    loadScene Level LevelMsg <| Level.init (getLevelData level)


loadTutorial : TutorialConfig -> Model -> ( Model, Cmd Msg )
loadTutorial config =
    loadScene Tutorial TutorialMsg <| Tutorial.init config


loadIntro : Model -> ( Model, Cmd Msg )
loadIntro =
    loadScene Intro IntroMsg Intro.init


loadHub : Int -> Model -> ( Model, Cmd Msg )
loadHub levelNumber =
    loadScene Hub HubMsg <| Hub.init levelNumber


loadSummary : Model -> Model
loadSummary model =
    { model | scene = Summary <| Scene.getShared model.scene }


loadRetry : Model -> Model
loadRetry model =
    { model | scene = Retry <| Scene.getShared model.scene }


loadScene :
    (subModel -> Scene)
    -> (subMsg -> Msg)
    -> (Shared.Data -> ( subModel, Cmd subMsg ))
    -> Model
    -> ( Model, Cmd Msg )
loadScene modelF msg initF model =
    Scene.getShared model.scene
        |> initF
        |> updateWith modelF msg model


updateWith : (sceneModel -> Scene) -> (sceneMsg -> Msg) -> Model -> ( sceneModel, Cmd sceneMsg ) -> ( Model, Cmd Msg )
updateWith toScene toMsg model ( subModel, subCmd ) =
    ( { model | scene = toScene subModel }
    , Cmd.map toMsg subCmd
    )



-- Scene updaters


handleTitleMsg : Title.Msg -> Model -> ( Model, Cmd Msg )
handleTitleMsg titleMsg model =
    case model.scene of
        Title titleModel ->
            Exit.handle
                { state = Title.update titleMsg titleModel
                , onContinue = updateWith Title TitleMsg model
                , onExit = exitTitle model
                }

        _ ->
            ( model, Cmd.none )


exitTitle : Model -> Title.Destination -> ( Model, Cmd Msg )
exitTitle model destination =
    case destination of
        Title.Hub ->
            ( model, trigger GoToHub )

        Title.Intro ->
            ( model, trigger LoadIntro )


handleLevelMsg : Level.Msg -> Model -> ( Model, Cmd Msg )
handleLevelMsg levelMsg model =
    case model.scene of
        Level levelModel ->
            Exit.handle
                { state = Level.update levelMsg levelModel
                , onContinue = updateWith Level LevelMsg model
                , onExit = exitLevel model
                }

        _ ->
            ( model, Cmd.none )


exitLevel : Model -> Level.Status -> ( Model, Cmd Msg )
exitLevel model levelStatus =
    case levelStatus of
        Level.Win ->
            ( model, trigger LevelWin )

        Level.Lose ->
            ( model, trigger LevelLose )

        Level.InProgress ->
            ( model, Cmd.none )


handleTutorialMsg : TutorialMsg -> Model -> ( Model, Cmd Msg )
handleTutorialMsg tutorialMsg model =
    case model.scene of
        Tutorial tutorialModel ->
            Exit.handle
                { state = Tutorial.update tutorialMsg tutorialModel
                , onContinue = updateWith Tutorial TutorialMsg model

                -- FIXME need to load level
                , onExit = always ( model, Cmd.none )
                }

        _ ->
            ( model, Cmd.none )


handleHubMsg : Hub.Msg -> Model -> ( Model, Cmd Msg )
handleHubMsg hubMsg model =
    case model.scene of
        Hub hubModel ->
            Exit.handle
                { state = Hub.update hubMsg hubModel
                , onContinue = updateWith Hub HubMsg model
                , onExit = exitHub model
                }

        _ ->
            ( model, Cmd.none )


exitHub : Model -> Progress -> ( Model, Cmd Msg )
exitHub model level =
    ( model, trigger <| StartLevel level )


handleIntroMsg : Intro.Msg -> Model -> ( Model, Cmd Msg )
handleIntroMsg introMsg model =
    case model.scene of
        Intro introModel ->
            Exit.handle
                { state = Intro.update introMsg introModel
                , onContinue = updateWith Intro IntroMsg model
                , onExit = always ( model, Cmd.batch [ trigger GoToHub, fadeMusic () ] )
                }

        _ ->
            ( model, Cmd.none )



-- Misc


bounceKeyframes : Window.Size -> Cmd msg
bounceKeyframes window =
    generateBounceKeyframes <| ScaleConfig.baseTileSizeY * ScaleConfig.tileScaleFactor window


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
    -- FIXME put me in Success scene
    -- let
    --     shared =
    --         Scene.getShared model.scene
    --
    --     progress =
    --         incrementProgress allLevels shared.currentLevel shared.progress
    -- in
    -- ( { model | scene = Scene.map (incrementProgress allLevels) model.scene }
    -- , cacheProgress <| fromProgress progress
    -- )
    ( model, Cmd.none )


progressLevelNumber : Model -> Int
progressLevelNumber model =
    Scene.getShared model.scene
        |> .progress
        |> getLevelNumber


levelWinSequence : Model -> List ( Float, Msg )
levelWinSequence model =
    let
        backToHub =
            backToHubSequence <| levelCompleteScrollNumber model

        shared =
            Scene.getShared model.scene
    in
    if shouldIncrement shared.currentLevel shared.progress then
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
    let
        shared =
            Scene.getShared model.scene
    in
    if shouldIncrement shared.currentLevel shared.progress then
        progressLevelNumber model + 1

    else
        getLevelNumber <| Maybe.withDefault ( 1, 1 ) shared.currentLevel



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
    -- FIXME
    -- cacheTimes
    --     { timeTillNextLife = model.timeTillNextLife
    --     , lastPlayed = model.lastPlayed
    --     }
    Cmd.none


countDownToNextLife : Float -> Model -> Model
countDownToNextLife now model =
    -- FIXME
    -- if model.timeTillNextLife <= 0 then
    --     { model | lastPlayed = now }
    --
    -- else
    --     let
    --         newTimeTillNextLife =
    --             decrementAboveZero (now - model.lastPlayed) model.timeTillNextLife
    --
    --         lifeVal =
    --             floor <| livesLeft newTimeTillNextLife
    --     in
    --     { model
    --         | timeTillNextLife = newTimeTillNextLife
    --         , lastPlayed = now
    --     }
    model


currentLevel : Model -> Progress
currentLevel model =
    -- FIXME
    -- model.currentLevel |> Maybe.withDefault ( 1, 1 )
    ( 1, 1 )


livesLeft : Float -> Float
livesLeft timeTill =
    (timeTill - (lifeRecoveryInterval * maxLives)) / -lifeRecoveryInterval


addTimeTillNextLife : Model -> Model
addTimeTillNextLife model =
    -- FIXME
    -- { model | timeTillNextLife = model.timeTillNextLife + lifeRecoveryInterval }
    model


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
        , subscribeDecrement model
        , sceneSubscriptions model
        ]


subscribeDecrement : Model -> Sub Msg
subscribeDecrement model =
    -- FIXME
    -- if model.scene == Hub && model.timeTillNextLife > 0 then
    --     Time.every 100 UpdateTimes
    --
    -- else
    --     Time.every (10 * 1000) UpdateTimes
    Sub.none


sceneSubscriptions : Model -> Sub Msg
sceneSubscriptions model =
    case model.scene of
        Title titleModel ->
            Sub.map TitleMsg <| Title.subscriptions titleModel

        _ ->
            Sub.none
