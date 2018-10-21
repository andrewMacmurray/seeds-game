module App exposing (main)

import Browser
import Browser.Events exposing (onResize)
import Config.Scale as ScaleConfig
import Css.Color exposing (darkYellow, lightYellow)
import Css.Style exposing (backgroundColor, color, style)
import Data.Exit as Exit
import Data.Level.Types exposing (..)
import Data.Levels as Levels
import Data.Lives as Lives
import Helpers.Delay exposing (..)
import Html exposing (Html, div, p, span, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Html.Keyed as K
import Ports exposing (..)
import Scene exposing (Scene(..))
import Scenes.Hub as Hub
import Scenes.Intro as Intro
import Scenes.Level as Level
import Scenes.Retry as Retry
import Scenes.Summary as Summary
import Scenes.Title as Title
import Scenes.Tutorial as Tutorial
import Shared exposing (..)
import Time exposing (millisToPosix)
import Views.Animations exposing (animations)
import Views.Loading exposing (loadingScreen)
import Worlds



-- Program


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- Types


type alias Flags =
    { now : Int
    , lives : Maybe Lives.Cache
    , level : Maybe Levels.Cache
    , randomMessageIndex : Int
    , window : Window
    }


type alias Model =
    { scene : Scene
    , backdrop : Maybe Scene
    }


type Msg
    = TitleMsg Title.Msg
    | LevelMsg Level.Msg
    | TutorialMsg Tutorial.Msg
    | IntroMsg Intro.Msg
    | HubMsg Hub.Msg
    | IncrementSuccessMessageIndex
    | StartLevel Levels.Key
    | RestartLevel
    | LevelWin
    | LevelLose
    | LoadTutorial Tutorial.Config Levels.LevelConfig
    | LoadLevel Levels.LevelConfig
    | LoadIntro
    | LoadHub Levels.Key
    | LoadSummary
    | LoadRetry
    | ShowLoadingScreen
    | HideLoadingScreen
    | RandomBackground Background
    | SetCurrentLevel (Maybe Levels.Key)
    | GoToHub
    | ClearCache
    | WindowSize Int Int
    | UpdateTimes Time.Posix
    | IncrementProgress
    | DecrementLives



-- Init


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( initialState flags
    , bounceKeyframes flags.window
    )


initialState : Flags -> Model
initialState flags =
    { scene = Title <| Title.init <| initShared flags
    , backdrop = Nothing
    }


initShared : Flags -> Shared.Data
initShared flags =
    { window = flags.window
    , loadingScreen = Nothing
    , progress = initProgressFromCache flags.level
    , currentLevel = Nothing
    , successMessageIndex = flags.randomMessageIndex
    , lives = Lives.fromCache (millisToPosix flags.now) flags.lives
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
            case Worlds.tutorial level of
                Just tutorialConfig ->
                    ( model
                    , sequence
                        [ ( 600, SetCurrentLevel <| Just level )
                        , ( 10, ShowLoadingScreen )
                        , ( 2500, LoadTutorial tutorialConfig <| Worlds.levelConfig level )
                        , ( 500, HideLoadingScreen )
                        ]
                    )

                Nothing ->
                    ( model
                    , sequence
                        [ ( 600, SetCurrentLevel <| Just level )
                        , ( 10, ShowLoadingScreen )
                        , ( 1000, LoadLevel <| Worlds.levelConfig level )
                        , ( 2000, HideLoadingScreen )
                        ]
                    )

        RestartLevel ->
            ( model, withLoadingScreen <| LoadLevel <| Worlds.levelConfig <| currentLevel model )

        LoadTutorial tutorialConfig levelConfig ->
            loadTutorial tutorialConfig levelConfig model

        LoadLevel level ->
            loadLevel level model

        LoadIntro ->
            loadIntro model

        LoadHub level ->
            loadHub level model

        LoadSummary ->
            ( loadSummary model, Cmd.none )

        LoadRetry ->
            ( loadRetry model, Cmd.none )

        LevelWin ->
            ( model, sequence <| levelWinSequence model )

        LevelLose ->
            ( model, sequence <| levelLoseSequence model )

        ShowLoadingScreen ->
            ( model, generateBackground RandomBackground )

        RandomBackground bgColor ->
            ( { model | scene = Scene.map (showLoadingScreen bgColor) model.scene }, Cmd.none )

        HideLoadingScreen ->
            ( { model | scene = Scene.map hideLoadingScreen model.scene }, Cmd.none )

        SetCurrentLevel progress ->
            ( { model | scene = Scene.map (setCurrentLevel progress) model.scene }, Cmd.none )

        GoToHub ->
            ( model, withLoadingScreen <| LoadHub <| getProgress model )

        ClearCache ->
            ( model, clearCache )

        WindowSize width height ->
            ( { model | scene = Scene.map (setWindow width height) model.scene }
            , bounceKeyframes <| Window width height
            )

        UpdateTimes now ->
            updateTimes now model

        -- Summary and Retry
        IncrementProgress ->
            handleIncrementProgress model

        DecrementLives ->
            ( { model | scene = Scene.map decrementLife model.scene }, Cmd.none )


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


loadLevel : Levels.LevelConfig -> Model -> ( Model, Cmd Msg )
loadLevel config =
    loadScene Level LevelMsg <| Level.init config


loadTutorial : Tutorial.Config -> Levels.LevelConfig -> Model -> ( Model, Cmd Msg )
loadTutorial tutorialConfig levelConfig model =
    let
        ( m1, cmd1 ) =
            loadScene Tutorial TutorialMsg (Tutorial.init tutorialConfig) model

        ( m2, cmd2 ) =
            loadBackdrop Level LevelMsg (Level.init levelConfig) m1
    in
    ( m2, Cmd.batch [ cmd1, cmd2 ] )


loadIntro : Model -> ( Model, Cmd Msg )
loadIntro =
    loadScene Intro IntroMsg Intro.init


loadHub : Levels.Key -> Model -> ( Model, Cmd Msg )
loadHub level =
    loadScene Hub HubMsg <| Hub.init level


loadSummary : Model -> Model
loadSummary model =
    { model | scene = Summary <| Scene.getShared model.scene }


loadRetry : Model -> Model
loadRetry model =
    { model | scene = Retry <| Scene.getShared model.scene }


loadScene : (subModel -> Scene) -> (subMsg -> Msg) -> (Shared.Data -> ( subModel, Cmd subMsg )) -> Model -> ( Model, Cmd Msg )
loadScene modelF msg initF model =
    Scene.getShared model.scene
        |> initF
        |> updateWith modelF msg model


loadBackdrop : (subModel -> Scene) -> (subMsg -> Msg) -> (Shared.Data -> ( subModel, Cmd subMsg )) -> Model -> ( Model, Cmd Msg )
loadBackdrop modelF msg initF model =
    Scene.getShared model.scene
        |> initF
        |> updateBackdropWith modelF msg model


updateWith : (sceneModel -> Scene) -> (sceneMsg -> Msg) -> Model -> ( sceneModel, Cmd sceneMsg ) -> ( Model, Cmd Msg )
updateWith toScene toMsg model ( subModel, subCmd ) =
    ( { model | scene = toScene subModel }
    , Cmd.map toMsg subCmd
    )


updateBackdropWith : (sceneModel -> Scene) -> (sceneMsg -> Msg) -> Model -> ( sceneModel, Cmd sceneMsg ) -> ( Model, Cmd Msg )
updateBackdropWith toScene toMsg model ( subModel, subCmd ) =
    ( { model | backdrop = Just <| toScene subModel }
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
    let
        ( m1, cmd1 ) =
            handleLevelForegroundMsg levelMsg model

        ( m2, cmd2 ) =
            handleLevelBackdropMsg levelMsg m1
    in
    ( m2, Cmd.batch [ cmd1, cmd2 ] )


handleLevelForegroundMsg : Level.Msg -> Model -> ( Model, Cmd Msg )
handleLevelForegroundMsg levelMsg model =
    case model.scene of
        Level levelModel ->
            Exit.handle
                { state = Level.update levelMsg levelModel
                , onContinue = updateWith Level LevelMsg model
                , onExit = exitLevel model
                }

        _ ->
            ( model, Cmd.none )


handleLevelBackdropMsg : Level.Msg -> Model -> ( Model, Cmd Msg )
handleLevelBackdropMsg levelMsg model =
    case model.backdrop of
        Just (Level levelModel) ->
            Exit.handle
                { state = Level.update levelMsg levelModel
                , onContinue = updateBackdropWith Level LevelMsg model
                , onExit = always ( model, Cmd.none )
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


handleTutorialMsg : Tutorial.Msg -> Model -> ( Model, Cmd Msg )
handleTutorialMsg tutorialMsg model =
    case model.scene of
        Tutorial tutorialModel ->
            Exit.handle
                { state = Tutorial.update tutorialMsg tutorialModel
                , onContinue = updateWith Tutorial TutorialMsg model
                , onExit = always ( promoteBackdrop model, Cmd.none )
                }

        _ ->
            ( model, Cmd.none )


promoteBackdrop : Model -> Model
promoteBackdrop model =
    case model.backdrop of
        Just scene ->
            { model | scene = syncShared model scene, backdrop = Nothing }

        _ ->
            model


syncShared : Model -> Scene -> Scene
syncShared model scene =
    Scene.map (always <| Scene.getShared model.scene) scene


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


exitHub : Model -> Levels.Key -> ( Model, Cmd Msg )
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


updateTimes : Time.Posix -> Model -> ( Model, Cmd Msg )
updateTimes now model =
    let
        nextModel =
            { model | scene = Scene.map (updateLives now) model.scene }
    in
    ( nextModel, saveCurrentLives nextModel )


saveCurrentLives : Model -> Cmd Msg
saveCurrentLives model =
    model.scene
        |> Scene.getShared
        |> .lives
        |> Lives.toCache
        |> cacheLives


bounceKeyframes : Window -> Cmd msg
bounceKeyframes window =
    generateBounceKeyframes <| ScaleConfig.baseTileSizeY * ScaleConfig.tileScaleFactor window


initProgressFromCache : Maybe Levels.Cache -> Levels.Key
initProgressFromCache cachedLevel =
    cachedLevel
        |> Maybe.map Levels.fromCache
        |> Maybe.withDefault Levels.empty


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


getProgress : Model -> Levels.Key
getProgress model =
    Scene.getShared model.scene |> .progress


levelWinSequence : Model -> List ( Float, Msg )
levelWinSequence model =
    let
        backToHub =
            backToHubSequence <| levelCompleteKey model

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


backToHubSequence : Levels.Key -> List ( Float, Msg )
backToHubSequence level =
    [ ( 1000, LoadHub level )
    , ( 1500, HideLoadingScreen )
    , ( 500, SetCurrentLevel Nothing )
    ]


levelCompleteKey : Model -> Levels.Key
levelCompleteKey model =
    let
        shared =
            Scene.getShared model.scene
    in
    if shouldIncrement shared.currentLevel shared.progress then
        Worlds.next shared.progress

    else
        Maybe.withDefault Levels.empty shared.currentLevel


currentLevel : Model -> Levels.Key
currentLevel model =
    model.scene
        |> Scene.getShared
        |> .currentLevel
        |> Maybe.withDefault Levels.empty


shouldIncrement : Maybe Levels.Key -> Levels.Key -> Bool
shouldIncrement current progress =
    case current of
        Just key ->
            if not <| Levels.reached key progress then
                True

            else
                False

        Nothing ->
            False



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ onResize WindowSize
        , subscribeDecrement model
        , sceneSubscriptions model
        ]


subscribeDecrement : Model -> Sub Msg
subscribeDecrement model =
    Time.every 1000 UpdateTimes


sceneSubscriptions : Model -> Sub Msg
sceneSubscriptions model =
    case model.scene of
        Title titleModel ->
            Sub.map TitleMsg <| Title.subscriptions titleModel

        _ ->
            Sub.none



-- View


view : Model -> Html Msg
view model =
    div []
        [ animations
        , reset
        , loadingScreen <| Scene.getShared model.scene
        , keyedDiv <| renderScene model.scene
        , renderBackrop model.backdrop
        , background
        ]


renderBackrop : Maybe Scene -> Html Msg
renderBackrop backdrop =
    backdrop
        |> Maybe.map (renderScene >> keyedDiv)
        |> Maybe.withDefault (span [] [])


keyedDiv : List ( String, Html msg ) -> Html msg
keyedDiv =
    K.node "div" []


renderScene : Scene -> List ( String, Html Msg )
renderScene scene =
    case scene of
        Hub hubModel ->
            [ ( "hub", Hub.view hubModel |> Html.map HubMsg ) ]

        Intro introModel ->
            [ ( "intro", Intro.view introModel |> Html.map IntroMsg ) ]

        Title titleModel ->
            [ ( "title", Title.view titleModel |> Html.map TitleMsg ) ]

        Level levelModel ->
            [ ( "level", Level.view levelModel |> Html.map LevelMsg ) ]

        Tutorial tutorialModel ->
            [ ( "tutorial", Tutorial.view tutorialModel |> Html.map TutorialMsg )
            ]

        Summary summaryModel ->
            [ ( "summary", Summary.view summaryModel ) ]

        Retry retryModel ->
            [ ( "retry"
              , Retry.view { hub = GoToHub, restart = RestartLevel } retryModel
              )
            ]


reset : Html Msg
reset =
    p
        [ onClick ClearCache
        , class "dib top-0 right-1 tracked pointer f7 absolute z-999"
        , style [ color darkYellow ]
        ]
        [ text "reset" ]


background : Html msg
background =
    div
        [ style [ backgroundColor lightYellow ]
        , class "fixed w-100 h-100 top-0 left-0 z-0"
        ]
        []
