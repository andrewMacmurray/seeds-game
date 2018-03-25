module State exposing (..)

import Config.Levels exposing (..)
import Config.Scale as ScaleConfig
import Data.Background exposing (..)
import Data.InfoWindow as InfoWindow exposing (InfoWindow(..))
import Data.Level.Progress exposing (..)
import Data.Level.Types exposing (..)
import Data.Transit as Transit exposing (Transit(..))
import Dom.Scroll exposing (toY)
import Helpers.Delay exposing (..)
import Helpers.OutMsg exposing (returnWithOutMsg)
import Ports exposing (..)
import Scenes.Level.State as Level
import Scenes.Level.Types as Lv exposing (OutMsg(..))
import Scenes.Tutorial.State as Tutorial
import Scenes.Tutorial.Types as Tu exposing (OutMsg(..))
import Task
import Time exposing (Time, every, minute, second)
import Types exposing (..)
import Window exposing (resizes, size)


-- Init


init : Flags -> ( Model, Cmd Msg )
init flags =
    initialState flags
        ! [ getWindowSize
          , getExternalAnimations ScaleConfig.baseTileSizeY
          ]


initialState : Flags -> Model
initialState flags =
    { scene = Title
    , loadingScreen = Nothing
    , progress = flags.rawProgress |> toProgress |> Maybe.withDefault ( 1, 1 )
    , currentLevel = Nothing
    , lives = Transitioning 5
    , levelInfoWindow = Hidden
    , window = { height = 0, width = 0 }
    , lastPlayed = initTimeTillNextLife flags
    , timeTillNextLife = flags.times |> Maybe.map .timeTillNextLife |> Maybe.withDefault 0
    , xAnimations = ""
    }



-- Update


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LevelMsg levelMsg ->
            handleLevelMsg levelMsg model

        TutorialMsg tutorialMsg ->
            handleTutorialMsg tutorialMsg model

        ReceieveExternalAnimations animations ->
            { model | xAnimations = animations } ! []

        StartLevel level ->
            case tutorialData level of
                Just tutorialConfig ->
                    model
                        ! [ sequenceMs
                                [ ( 600, SetCurrentLevel <| Just level )
                                , ( 10, ShowLoadingScreen )
                                , ( 3000, HideLoadingScreen )
                                , ( 0, LoadTutorial level tutorialConfig )
                                ]
                          ]

                Nothing ->
                    model
                        ! [ sequenceMs
                                [ ( 600, SetCurrentLevel <| Just level )
                                , ( 10, ShowLoadingScreen )
                                , ( 500, LoadLevel <| getLevelData level )
                                , ( 2500, HideLoadingScreen )
                                ]
                          ]

        RestartLevel ->
            model
                ! [ sequenceMs
                        [ ( 10, ShowLoadingScreen )
                        , ( 500, LoadLevel <| currentLevelData model )
                        , ( 2500, HideLoadingScreen )
                        ]
                  ]

        LoadTutorial level config ->
            handleLoadTutorial model level config

        LoadLevel levelData ->
            handleLoadLevel model levelData

        LoadHub ->
            handleLoadHub model ! []

        LoadSummary ->
            handleLoadSummary model ! []

        LoadRetry ->
            handleLoadRetry model ! []

        TransitionWithWin ->
            model ! [ sequenceMs <| levelWinSequence model ]

        TransitionWithLose ->
            model ! [ sequenceMs <| levelLoseSequence model ]

        ShowLoadingScreen ->
            model ! [ genRandomBackground RandomBackground ]

        HideLoadingScreen ->
            { model | loadingScreen = Nothing } ! []

        SetCurrentLevel progress ->
            { model | currentLevel = progress } ! []

        GoToHub ->
            model
                ! [ sequenceMs
                        [ ( 0, ShowLoadingScreen )
                        , ( 500, LoadHub )
                        , ( 100, ScrollToHubLevel <| progressLevelNumber model )
                        , ( 2400, HideLoadingScreen )
                        ]
                  ]

        SetInfoState infoWindow ->
            { model | levelInfoWindow = infoWindow } ! []

        ShowInfo levelProgress ->
            { model | levelInfoWindow = Visible levelProgress } ! []

        HideInfo ->
            model
                ! [ sequenceMs
                        [ ( 0, SetInfoState <| InfoWindow.toHiding model.levelInfoWindow )
                        , ( 1000, SetInfoState Hidden )
                        ]
                  ]

        RandomBackground background ->
            { model | loadingScreen = Just background } ! []

        IncrementProgress ->
            handleIncrementProgress model

        DecrementLives ->
            (model
                |> handleDecrementLives
                |> addTimeTillNextLife
            )
                ! []

        ScrollToHubLevel level ->
            model ! [ scrollToHubLevel level ]

        ReceiveHubLevelOffset offset ->
            model ! [ scrollHubToLevel offset model.window ]

        ClearCache ->
            model ! [ clearCache ]

        DomNoOp _ ->
            model ! []

        WindowSize size ->
            { model | window = size }
                ! [ getExternalAnimations <| ScaleConfig.baseTileSizeY * ScaleConfig.tileScaleFactor size ]

        Tick time ->
            handleUpdateTimes time model



-- Update Helpers


getWindowSize : Cmd Msg
getWindowSize =
    Task.perform WindowSize size


scrollHubToLevel : Float -> Window.Size -> Cmd Msg
scrollHubToLevel offset window =
    let
        targetDistance =
            offset - toFloat (window.height // 2) + 60
    in
        toY "hub" targetDistance |> Task.attempt DomNoOp


getLevelData : Progress -> LevelData Tu.Config
getLevelData =
    levelData allLevels >> Maybe.withDefault defaultLevel


getLevelConfig : Progress -> CurrentLevelConfig Tu.Config
getLevelConfig =
    levelConfig allLevels >> Maybe.withDefault ( defaultWorld, defaultLevel )



-- Scene Loaders


handleLoadLevel : Model -> LevelData config -> ( Model, Cmd Msg )
handleLoadLevel model levelData =
    let
        ( levelModel, levelCmd ) =
            Level.init levelData Level.initialState
    in
        { model | scene = Level levelModel }
            ! [ Cmd.map LevelMsg levelCmd
              , getWindowSize
              ]


handleLoadTutorial : Model -> Progress -> Tu.Config -> ( Model, Cmd Msg )
handleLoadTutorial model level tutorialConfig =
    let
        ( tutorialModel, tutorialCmd ) =
            Tutorial.init tutorialConfig

        ( levelModel, levelCmd ) =
            Level.init (getLevelData level) Level.initialState
    in
        { model | scene = Tutorial tutorialModel (Backdrop levelModel) }
            ! [ Cmd.map TutorialMsg tutorialCmd
              , Cmd.map LevelMsg levelCmd
              , getWindowSize
              ]


handleLoadHub : Model -> Model
handleLoadHub model =
    { model | scene = Hub }


handleLoadSummary : Model -> Model
handleLoadSummary model =
    case model.scene of
        Level levelModel ->
            { model | scene = Summary (Backdrop levelModel) }

        _ ->
            model


handleLoadRetry : Model -> Model
handleLoadRetry model =
    case model.scene of
        Level levelModel ->
            { model
                | scene = Retry (Backdrop levelModel)
                , lives = Transit.toStatic model.lives
            }

        _ ->
            model



-- Scene updaters


handleLevelMsg : Lv.Msg -> Model -> ( Model, Cmd Msg )
handleLevelMsg levelMsg model =
    let
        returnLevel lm f =
            Level.update levelMsg lm
                |> returnWithOutMsg f LevelMsg
                |> handleLevelOutMsg

        toScene f lm =
            { model | scene = f lm }
    in
        case model.scene of
            Level lm ->
                returnLevel lm (toScene Level)

            Tutorial tuM (Backdrop lm) ->
                returnLevel lm (toScene <| Tutorial tuM << Backdrop)

            Retry (Backdrop lm) ->
                returnLevel lm (toScene <| Retry << Backdrop)

            Summary (Backdrop lm) ->
                returnLevel lm (toScene <| Summary << Backdrop)

            _ ->
                model ! []


handleLevelOutMsg : ( Model, Cmd Msg, Maybe Lv.OutMsg ) -> ( Model, Cmd Msg )
handleLevelOutMsg ( model, cmd, outMsg ) =
    case outMsg of
        Just ExitLevelWithWin ->
            model ! [ trigger TransitionWithWin, cmd ]

        Just ExitLevelWithLose ->
            model ! [ trigger TransitionWithLose, cmd ]

        Nothing ->
            model ! [ cmd ]


handleTutorialMsg : Tu.Msg -> Model -> ( Model, Cmd Msg )
handleTutorialMsg tutorialMsg model =
    case model.scene of
        Tutorial tutorialModel bg ->
            Tutorial.update tutorialMsg tutorialModel
                |> returnWithOutMsg (\tm -> { model | scene = Tutorial tm bg }) TutorialMsg
                |> handleTutorialOutMsg

        _ ->
            model ! []


handleTutorialOutMsg : ( Model, Cmd Msg, Maybe Tu.OutMsg ) -> ( Model, Cmd Msg )
handleTutorialOutMsg ( model, cmd, outMsg ) =
    case outMsg of
        Just ExitTutorialToLevel ->
            { model | scene = tutorialToLevel model.scene } ! [ cmd ]

        Nothing ->
            model ! [ cmd ]


tutorialToLevel : Scene -> Scene
tutorialToLevel scene =
    case scene of
        Tutorial _ (Backdrop lm) ->
            Level lm

        _ ->
            scene



-- Misc


tutorialData : Progress -> Maybe Tu.Config
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
    [ ( 500, LoadHub )
    , ( 1000, ScrollToHubLevel levelNumber )
    , ( 1500, HideLoadingScreen )
    , ( 500, SetCurrentLevel Nothing )
    ]


levelCompleteScrollNumber : Model -> Int
levelCompleteScrollNumber model =
    if shouldIncrement allLevels model.currentLevel model.progress then
        progressLevelNumber model + 1
    else
        getLevelNumber (Maybe.withDefault ( 1, 1 ) model.currentLevel) allLevels



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ receiveExternalAnimations ReceieveExternalAnimations
        , receiveHubLevelOffset ReceiveHubLevelOffset
          -- , every second Tick
        , resizes WindowSize
        , levelSubscriptions model
        , tutorialSubscriptions model
        ]


levelSubscriptions : Model -> Sub Msg
levelSubscriptions model =
    let
        levelSub lm =
            Sub.map LevelMsg <| Level.subscriptions lm
    in
        case model.scene of
            Level levelModel ->
                levelSub levelModel

            Tutorial tuM (Backdrop lm) ->
                levelSub lm

            Retry (Backdrop lm) ->
                levelSub lm

            Summary (Backdrop lm) ->
                levelSub lm

            _ ->
                Sub.none


tutorialSubscriptions : Model -> Sub Msg
tutorialSubscriptions model =
    case model.scene of
        Tutorial tuM _ ->
            Sub.map TutorialMsg <| Tutorial.subscriptions tuM

        _ ->
            Sub.none



-- Life Timers


initTimeTillNextLife : Flags -> Time
initTimeTillNextLife flags =
    flags.times
        |> Maybe.map (\t -> decrementAboveZero (flags.now - t.lastPlayed) t.timeTillNextLife)
        |> Maybe.withDefault 0


handleUpdateTimes : Time -> Model -> ( Model, Cmd Msg )
handleUpdateTimes time model =
    let
        newModel =
            { model | lastPlayed = time } |> countDownToNextLife
    in
        newModel ! [ handleCacheTimes newModel ]


handleCacheTimes : Model -> Cmd msg
handleCacheTimes model =
    cacheTimes
        { timeTillNextLife = model.timeTillNextLife
        , lastPlayed = model.lastPlayed
        }


countDownToNextLife : Model -> Model
countDownToNextLife model =
    if model.timeTillNextLife <= 0 then
        model
    else
        { model
            | timeTillNextLife = model.timeTillNextLife - second
            , lives = Transit.map (always <| countDown model.timeTillNextLife) model.lives
        }


countDown : Float -> Int
countDown timeTillNextLife =
    floor <| livesLeft <| timeTillNextLife - second


currentLevelData : Model -> LevelData Tu.Config
currentLevelData model =
    model.currentLevel
        |> Maybe.withDefault ( 1, 1 )
        |> getLevelData


livesLeft : Time -> Float
livesLeft timeTill =
    (timeTill - (lifeRecoveryInterval * maxLives)) / -lifeRecoveryInterval


addTimeTillNextLife : Model -> Model
addTimeTillNextLife model =
    { model | timeTillNextLife = model.timeTillNextLife + lifeRecoveryInterval }


handleDecrementLives : Model -> Model
handleDecrementLives model =
    { model | lives = decrementLives model.lives }


decrementLives : Transit Int -> Transit Int
decrementLives lifeState =
    lifeState
        |> Transit.map (decrementAboveZero 1)
        |> Transit.toTransitioning


decrementAboveZero : number -> number -> number
decrementAboveZero x n =
    clamp 0 100000000000 (n - x)
