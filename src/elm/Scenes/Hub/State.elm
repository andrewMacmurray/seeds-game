module Scenes.Hub.State exposing (..)

import Config.Levels exposing (..)
import Config.Scale as ScaleConfig
import Data.Background exposing (..)
import Data.InfoWindow as InfoWindow exposing (InfoWindow(..))
import Data.Level.Progress exposing (..)
import Data.Level.Types exposing (..)
import Data.Transit as Transit exposing (Transit(..))
import Helpers.Effect exposing (..)
import Helpers.OutMsg exposing (returnWithOutMsg)
import Mouse exposing (downs, moves)
import Ports exposing (..)
import Scenes.Hub.Types exposing (..)
import Scenes.Level.State as Level
import Scenes.Level.Types as Lv exposing (OutMsg(..))
import Scenes.Tutorial.State as Tutorial
import Scenes.Tutorial.Types as Tu exposing (OutMsg(..))
import Task
import Time exposing (Time, every, minute, second)
import Types exposing (Flags, Times, fromProgress, toProgress)
import Window exposing (resizes, size)


-- Init


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        state =
            initialState flags

        ( model, loadLevelCmd ) =
            handleLoadLevel state <| getLevelData state.progress
    in
        model
            ! [ getWindowSize
              , getExternalAnimations ScaleConfig.baseTileSizeY
              , Cmd.map LevelMsg Level.generateSuccessMessageIndex
              , loadLevelCmd
              ]


initialState : Flags -> Model
initialState flags =
    { levelModel = Level.initialState
    , tutorialModel = Tutorial.initialState
    , xAnimations = ""
    , scene = Title
    , sceneTransition = False
    , transitionBackground = Orange
    , progress = flags.rawProgress |> toProgress |> Maybe.withDefault ( 1, 1 )
    , currentLevel = Nothing
    , lives = Stationary 5
    , infoWindow = Hidden
    , window = { height = 0, width = 0 }
    , mouse = { y = 0, x = 0 }
    , lastPlayed = initTimeTillNextLife flags
    , timeTillNextLife = flags.times |> Maybe.map .timeTillNextLife |> Maybe.withDefault 0
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
                                , ( 10, BeginSceneTransition )
                                , ( 500, SetScene Tutorial )
                                , ( 0, LoadLevel <| getLevelData level )
                                , ( 2500, EndSceneTransition )
                                , ( 500, LoadTutorial tutorialConfig )
                                ]
                          ]

                Nothing ->
                    model
                        ! [ sequenceMs
                                [ ( 600, SetCurrentLevel <| Just level )
                                , ( 10, BeginSceneTransition )
                                , ( 500, SetScene Level )
                                , ( 0, LoadLevel <| getLevelData level )
                                , ( 2500, EndSceneTransition )
                                ]
                          ]

        RestartLevel ->
            model
                ! [ sequenceMs
                        [ ( 10, BeginSceneTransition )
                        , ( 500, SetScene Level )
                        , ( 0, LoadLevel <| currentLevelData model )
                        , ( 2500, EndSceneTransition )
                        ]
                  ]

        LoadTutorial config ->
            handleLoadTutorial model config

        LoadLevel levelData ->
            handleLoadLevel model levelData

        TransitionWithWin ->
            model ! [ sequenceMs <| levelWinSequence model ]

        TransitionWithLose ->
            model ! [ sequenceMs <| levelLoseSequence model ]

        SetScene scene ->
            { model | scene = scene } ! []

        BeginSceneTransition ->
            { model | sceneTransition = True } ! [ genRandomBackground RandomBackground ]

        EndSceneTransition ->
            { model | sceneTransition = False } ! []

        SetCurrentLevel progress ->
            { model | currentLevel = progress } ! []

        GoToHub ->
            model
                ! [ sequenceMs
                        [ ( 0, BeginSceneTransition )
                        , ( 500, SetScene Hub )
                        , ( 100, ScrollToHubLevel <| progressLevelNumber model )
                        , ( 2400, EndSceneTransition )
                        ]
                  ]

        GoToRetry ->
            { model | scene = Retry, lives = Transit.toStationary model.lives } ! []

        SetInfoState infoWindow ->
            { model | infoWindow = infoWindow } ! []

        ShowInfo levelProgress ->
            { model | infoWindow = Visible levelProgress } ! []

        HideInfo ->
            model
                ! [ sequenceMs
                        [ ( 0, SetInfoState <| InfoWindow.toHiding model.infoWindow )
                        , ( 1000, SetInfoState Hidden )
                        ]
                  ]

        RandomBackground background ->
            { model | transitionBackground = background } ! []

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
            model ! [ scrollHubToLevel DomNoOp offset model.window ]

        ClearCache ->
            model ! [ clearCache ]

        DomNoOp _ ->
            model ! []

        WindowSize size ->
            { model
                | levelModel = addWindowSizeToLevel size model
                , tutorialModel = addWindowSizeToTutorial size model
                , window = size
            }
                ! [ getExternalAnimations <| ScaleConfig.baseTileSizeY * ScaleConfig.tileScaleFactor size ]

        MousePosition position ->
            { model | levelModel = addMousePositionToLevel position model } ! []

        Tick time ->
            handleUpdateTimes time model



-- Update Helpers


getWindowSize : Cmd Msg
getWindowSize =
    Task.perform WindowSize size


getLevelData : Progress -> LevelData Tu.Config
getLevelData =
    levelData allLevels >> Maybe.withDefault defaultLevel


getLevelConfig : Progress -> CurrentLevelConfig Tu.Config
getLevelConfig =
    levelConfig allLevels >> Maybe.withDefault ( defaultWorld, defaultLevel )


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


handleLoadLevel : Model -> LevelData config -> ( Model, Cmd Msg )
handleLoadLevel model levelData =
    let
        ( levelModel, levelCmd ) =
            Level.init levelData
    in
        { model | levelModel = levelModel } ! [ Cmd.map LevelMsg levelCmd ]


handleLoadTutorial : Model -> Tu.Config -> ( Model, Cmd Msg )
handleLoadTutorial model tutorialConfig =
    let
        ( tutorialModel, tutorialCmd ) =
            Tutorial.init tutorialConfig
    in
        { model | tutorialModel = tutorialModel } ! [ Cmd.map TutorialMsg tutorialCmd ]


tutorialData : Progress -> Maybe Tu.Config
tutorialData level =
    let
        ( _, levelData ) =
            getLevelConfig level
    in
        levelData.tutorial


addMousePositionToLevel : Mouse.Position -> Model -> Lv.Model
addMousePositionToLevel position { levelModel } =
    { levelModel | mouse = position }


addWindowSizeToLevel : Window.Size -> Model -> Lv.Model
addWindowSizeToLevel window { levelModel } =
    { levelModel | window = window }


addWindowSizeToTutorial : Window.Size -> Model -> Tu.Model
addWindowSizeToTutorial window { tutorialModel } =
    { tutorialModel | window = window }


handleLevelMsg : Lv.Msg -> Model -> ( Model, Cmd Msg )
handleLevelMsg levelMsg model =
    Level.update levelMsg model.levelModel
        |> returnWithOutMsg (embedLevelModel model) LevelMsg
        |> handleLevelOutMsg


handleLevelOutMsg : ( Model, Cmd Msg, Maybe Lv.OutMsg ) -> ( Model, Cmd Msg )
handleLevelOutMsg ( model, cmd, outMsg ) =
    case outMsg of
        Just ExitLevelWithWin ->
            model ! [ trigger TransitionWithWin, cmd ]

        Just ExitLevelWithLose ->
            model ! [ trigger TransitionWithLose, cmd ]

        Nothing ->
            model ! [ cmd ]


embedLevelModel : Model -> (Lv.Model -> Model)
embedLevelModel model levelModel =
    { model | levelModel = levelModel }


handleTutorialMsg : Tu.Msg -> Model -> ( Model, Cmd Msg )
handleTutorialMsg tutorialMsg m =
    Tutorial.update tutorialMsg m.tutorialModel
        |> returnWithOutMsg (embedTutorialModel m) TutorialMsg
        |> handleTutorialOutMsg


handleTutorialOutMsg : ( Model, Cmd Msg, Maybe Tu.OutMsg ) -> ( Model, Cmd Msg )
handleTutorialOutMsg ( model, cmd, outMsg ) =
    case outMsg of
        Just ExitTutorialToLevel ->
            if not model.tutorialModel.skipped then
                { model | scene = Level } ! [ cmd ]
            else
                model ! [ cmd ]

        Nothing ->
            model ! [ cmd ]


embedTutorialModel : Model -> (Tu.Model -> Model)
embedTutorialModel model tutorialModel =
    { model | tutorialModel = tutorialModel }


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
            [ ( 0, SetScene Summary )
            , ( 2000, IncrementProgress )
            , ( 2500, BeginSceneTransition )
            ]
                ++ backToHub
        else
            ( 0, BeginSceneTransition ) :: backToHub


levelLoseSequence : Model -> List ( Float, Msg )
levelLoseSequence model =
    [ ( 0, GoToRetry )
    , ( 1000, DecrementLives )
    ]


backToHubSequence : Int -> List ( Float, Msg )
backToHubSequence levelNumber =
    [ ( 500, SetScene Hub )
    , ( 1000, ScrollToHubLevel levelNumber )
    , ( 1500, EndSceneTransition )
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
        [ resizes WindowSize
        , downs MousePosition
        , trackMousePosition model
        , receiveExternalAnimations ReceieveExternalAnimations
        , receiveHubLevelOffset ReceiveHubLevelOffset
        , every second Tick
        ]


trackMousePosition : Model -> Sub Msg
trackMousePosition model =
    if model.levelModel.isDragging then
        moves MousePosition
    else
        Sub.none
