module Main exposing (main)

import Browser
import Browser.Events exposing (onResize)
import Context exposing (..)
import Css.Color as Color
import Css.Style exposing (backgroundColor, color, style)
import Data.Board.Tile as Tile
import Data.Level.Types exposing (..)
import Data.Levels as Levels
import Data.Lives as Lives
import Data.Progress as Progress exposing (Progress)
import Data.Window exposing (Window)
import Exit
import Helpers.Delay as Delay exposing (trigger)
import Helpers.Return as Return
import Html exposing (Html, div, p, span, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Html.Keyed as Keyed
import Ports exposing (..)
import Scene exposing (Scene(..))
import Scenes.Garden as Garden
import Scenes.Hub as Hub
import Scenes.Intro as Intro
import Scenes.Level as Level
import Scenes.Retry as Retry
import Scenes.Summary as Summary
import Scenes.Title as Title
import Scenes.Tutorial as Tutorial
import Time exposing (millisToPosix)
import Views.Animations exposing (animations)
import Views.Loading exposing (loadingScreen)
import Views.Menu as Menu
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



-- Model


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
    | IntroMsg Intro.Msg
    | HubMsg Hub.Msg
    | TutorialMsg Tutorial.Msg
    | LevelMsg Level.Msg
    | RetryMsg Retry.Msg
    | SummaryMsg Summary.Msg
    | GardenMsg Garden.Msg
    | InitIntro
    | InitHub Levels.Key
    | InitTutorial Tutorial.Config Levels.LevelConfig
    | InitLevel Levels.LevelConfig
    | InitRetry
    | InitSummary
    | InitGarden
    | ShowLoadingScreen
    | HideLoadingScreen
    | OpenMenu
    | CloseMenu
    | RandomBackground Background
    | ResetData
    | WindowSize Int Int
    | UpdateTimes Time.Posix
    | GoToHub Levels.Key



-- Init


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( initialState flags
    , bounceKeyframes flags.window
    )


initialState : Flags -> Model
initialState flags =
    { scene = Title <| Title.init <| initialContext flags
    , backdrop = Nothing
    }


initialContext : Flags -> Context
initialContext flags =
    { window = flags.window
    , loadingScreen = Nothing
    , progress = Progress.fromCache flags.level
    , lives = Lives.fromCache (millisToPosix flags.now) flags.lives
    , successMessageIndex = flags.randomMessageIndex
    , menu = Context.Closed
    }



-- Update


update : Msg -> Model -> ( Model, Cmd Msg )
update msg ({ scene, backdrop } as model) =
    case ( msg, scene, backdrop ) of
        ( TitleMsg title, Title titleModel, _ ) ->
            updateTitle title titleModel model

        ( IntroMsg intro, Intro introModel, _ ) ->
            updateIntro intro introModel model

        ( HubMsg hub, Hub hubModel, _ ) ->
            updateHub hub hubModel model

        ( TutorialMsg tutorial, Tutorial tutorialModel, _ ) ->
            updateTutorial tutorial tutorialModel model

        ( LevelMsg level, Level levelModel, _ ) ->
            updateLevel level levelModel model

        ( LevelMsg level, _, Just (Level levelModel) ) ->
            updateLevelBackdrop level levelModel model

        ( RetryMsg retry, Retry retryModel, _ ) ->
            updateRetry retry retryModel model

        ( SummaryMsg summary, Summary summaryModel, _ ) ->
            updateSummary summary summaryModel model

        ( GardenMsg garden, Garden gardenModel, _ ) ->
            updateGarden garden gardenModel model

        ( InitIntro, _, _ ) ->
            initIntro model

        ( InitHub level, _, _ ) ->
            initHub level model

        ( InitTutorial tutorialConfig levelConfig, _, _ ) ->
            initTutorial tutorialConfig levelConfig model

        ( InitLevel level, _, _ ) ->
            initLevel level model

        ( InitRetry, _, _ ) ->
            initRetry model

        ( InitSummary, _, _ ) ->
            initSummary model

        ( InitGarden, _, _ ) ->
            initGarden model

        ( ShowLoadingScreen, _, _ ) ->
            ( model, generateBackground RandomBackground )

        ( RandomBackground bgColor, _, _ ) ->
            ( updateContext model <| showLoadingScreen bgColor, Cmd.none )

        ( HideLoadingScreen, _, _ ) ->
            ( updateContext model hideLoadingScreen, Cmd.none )

        ( OpenMenu, _, _ ) ->
            ( updateContext model openMenu, Cmd.none )

        ( CloseMenu, _, _ ) ->
            ( updateContext model closeMenu, Cmd.none )

        ( GoToHub level, _, _ ) ->
            ( model, withLoadingScreen <| InitHub level )

        ( ResetData, _, _ ) ->
            ( model, clearCache )

        ( WindowSize width height, _, _ ) ->
            ( updateContext model <| setWindow width height
            , bounceKeyframes <| Window width height
            )

        ( UpdateTimes now, _, _ ) ->
            updateTimes now model

        _ ->
            ( model, Cmd.none )



-- Title


updateTitle : Title.Msg -> Title.Model -> Model -> ( Model, Cmd Msg )
updateTitle =
    updateScene Title TitleMsg Title.update |> Exit.onExit exitTitle


exitTitle : Model -> Title.Destination -> ( Model, Cmd Msg )
exitTitle model destination =
    case destination of
        Title.ToHub ->
            ( model, goToHubReachedLevel model )

        Title.ToIntro ->
            ( model, trigger InitIntro )

        Title.ToGarden ->
            ( model, goToGarden )



-- Intro


initIntro : Model -> ( Model, Cmd Msg )
initIntro =
    initScene Intro IntroMsg Intro.init


updateIntro : Intro.Msg -> Intro.Model -> Model -> ( Model, Cmd Msg )
updateIntro =
    updateScene Intro IntroMsg Intro.update |> Exit.onExit exitIntro


exitIntro : Model -> () -> ( Model, Cmd Msg )
exitIntro model _ =
    ( model, Cmd.batch [ goToHubReachedLevel model, fadeMusic () ] )



-- Hub


initHub : Levels.Key -> Model -> ( Model, Cmd Msg )
initHub level =
    initScene Hub HubMsg <| Hub.init level


updateHub : Hub.Msg -> Hub.Model -> Model -> ( Model, Cmd Msg )
updateHub =
    updateScene Hub HubMsg Hub.update |> Exit.onExit exitHub


exitHub : Model -> Hub.Destination -> ( Model, Cmd Msg )
exitHub model destination =
    case destination of
        Hub.ToLevel level ->
            handleStartLevel model level

        Hub.ToGarden ->
            ( model, goToGarden )


handleStartLevel : Model -> Levels.Key -> ( Model, Cmd Msg )
handleStartLevel model level =
    case Worlds.tutorial level of
        Just tutorialConfig ->
            ( model, withLoadingScreen <| InitTutorial tutorialConfig <| Worlds.levelConfig level )

        Nothing ->
            ( model, withLoadingScreen <| InitLevel <| Worlds.levelConfig level )



-- Tutorial


initTutorial : Tutorial.Config -> Levels.LevelConfig -> Model -> ( Model, Cmd Msg )
initTutorial tutorialConfig levelConfig model =
    Return.pipe model
        [ initScene Tutorial TutorialMsg (Tutorial.init tutorialConfig)
        , initBackdrop Level LevelMsg (Level.init levelConfig)
        ]


updateTutorial : Tutorial.Msg -> Tutorial.Model -> Model -> ( Model, Cmd Msg )
updateTutorial =
    updateScene Tutorial TutorialMsg Tutorial.update |> Exit.onExit exitTutorial


exitTutorial : Model -> () -> ( Model, Cmd Msg )
exitTutorial model _ =
    ( moveBackdropToScene model, Cmd.none )



-- Level


initLevel : Levels.LevelConfig -> Model -> ( Model, Cmd Msg )
initLevel config =
    initScene Level LevelMsg <| Level.init config


updateLevel : Level.Msg -> Level.Model -> Model -> ( Model, Cmd Msg )
updateLevel =
    updateScene Level LevelMsg Level.update |> Exit.onExit exitLevel


updateLevelBackdrop : Level.Msg -> Level.Model -> Model -> ( Model, Cmd Msg )
updateLevelBackdrop =
    updateBackdrop Level LevelMsg Level.update |> Exit.ignore


exitLevel : Model -> Level.Status -> ( Model, Cmd Msg )
exitLevel model levelStatus =
    case levelStatus of
        Level.Win ->
            levelWin model

        Level.Lose ->
            ( model, trigger InitRetry )

        Level.Restart ->
            ( model, reloadCurrentLevel model )

        Level.Exit ->
            ( model, goToHubCurrentLevel model )

        Level.NotStarted ->
            ( model, Cmd.none )

        Level.InProgress ->
            ( model, Cmd.none )


levelWin : Model -> ( Model, Cmd Msg )
levelWin model =
    if shouldIncrement <| Scene.getContext model.scene then
        ( model, trigger InitSummary )

    else
        ( model, goToHubCurrentLevel model )



-- Retry


initRetry : Model -> ( Model, Cmd Msg )
initRetry =
    copyCurrentSceneToBackdrop >> initScene Retry RetryMsg Retry.init


updateRetry : Retry.Msg -> Retry.Model -> Model -> ( Model, Cmd Msg )
updateRetry =
    updateScene Retry RetryMsg Retry.update |> Exit.onExit exitRetry


exitRetry : Model -> Retry.Destination -> ( Model, Cmd Msg )
exitRetry model destination =
    case destination of
        Retry.ToLevel ->
            ( clearBackdrop model, reloadCurrentLevel model )

        Retry.ToHub ->
            ( clearBackdrop model, goToHubCurrentLevel model )



-- Summary


initSummary : Model -> ( Model, Cmd Msg )
initSummary =
    copyCurrentSceneToBackdrop >> initScene Summary SummaryMsg Summary.init


updateSummary : Summary.Msg -> Summary.Model -> Model -> ( Model, Cmd Msg )
updateSummary =
    updateScene Summary SummaryMsg Summary.update |> Exit.onExit exitSummary


exitSummary : Model -> Summary.Destination -> ( Model, Cmd Msg )
exitSummary model destination =
    case destination of
        Summary.ToHub ->
            ( clearBackdrop model, goToHubReachedLevel model )

        Summary.ToGarden ->
            ( clearBackdrop model, trigger InitGarden )



-- Garden


initGarden : Model -> ( Model, Cmd Msg )
initGarden =
    initScene Garden GardenMsg Garden.init


updateGarden : Garden.Msg -> Garden.Model -> Model -> ( Model, Cmd Msg )
updateGarden =
    updateScene Garden GardenMsg Garden.update |> Exit.onExit exitGarden


exitGarden : Model -> () -> ( Model, Cmd Msg )
exitGarden model _ =
    ( model, goToHubReachedLevel model )



-- Util


initScene =
    load asForeground


initBackdrop =
    load asBackdrop


updateScene sceneF =
    Exit.handle (composeScene sceneF asForeground)


updateBackdrop sceneF =
    Exit.handle (composeScene sceneF asBackdrop)


load embedModel embedScene msg initSceneF model =
    Scene.getContext model.scene
        |> closeMenu
        |> initSceneF
        |> Return.map msg (embedScene >> embedModel model)


composeScene : (subModel -> Scene) -> (Model -> Scene -> Model) -> (subModel -> Model -> Model)
composeScene sceneF modelF sceneModel model =
    modelF model (sceneF sceneModel)


asForeground : Model -> Scene -> Model
asForeground model scene =
    { model | scene = scene }


asBackdrop : Model -> Scene -> Model
asBackdrop model scene =
    { model | backdrop = Just scene }


copyCurrentSceneToBackdrop : Model -> Model
copyCurrentSceneToBackdrop model =
    { model | backdrop = Just model.scene }


clearBackdrop : Model -> Model
clearBackdrop model =
    { model | backdrop = Nothing }


moveBackdropToScene : Model -> Model
moveBackdropToScene model =
    case model.backdrop of
        Just scene ->
            { model | scene = syncContext model scene, backdrop = Nothing }

        _ ->
            model


syncContext : Model -> Scene -> Scene
syncContext model scene =
    Scene.map (always <| Scene.getContext model.scene) scene


updateContext : Model -> (Context -> Context) -> Model
updateContext model f =
    { model | scene = Scene.map f model.scene }



-- Misc


withLoadingScreen : Msg -> Cmd Msg
withLoadingScreen msg =
    Delay.sequence
        [ ( 0, ShowLoadingScreen )
        , ( 1000, msg )
        , ( 2000, HideLoadingScreen )
        ]


goToGarden : Cmd Msg
goToGarden =
    Delay.sequence
        [ ( 0, ShowLoadingScreen )
        , ( 3000, HideLoadingScreen )
        , ( 0, InitGarden )
        ]


reloadCurrentLevel : Model -> Cmd Msg
reloadCurrentLevel =
    withLoadingScreen << InitLevel << Worlds.levelConfig << currentLevel


goToHubCurrentLevel : Model -> Cmd Msg
goToHubCurrentLevel =
    trigger << GoToHub << currentLevel


goToHubReachedLevel : Model -> Cmd Msg
goToHubReachedLevel =
    trigger << GoToHub << reachedLevel


updateTimes : Time.Posix -> Model -> ( Model, Cmd Msg )
updateTimes now model =
    { model | scene = Scene.map (updateLives now) model.scene } |> andCmd saveCurrentLives


andCmd : (Model -> Cmd Msg) -> Model -> ( Model, Cmd Msg )
andCmd cmdF model =
    ( model, cmdF model )


saveCurrentLives : Model -> Cmd Msg
saveCurrentLives model =
    model.scene
        |> (Scene.getContext >> .lives)
        |> (Lives.toCache >> cacheLives)


bounceKeyframes : Window -> Cmd msg
bounceKeyframes window =
    generateBounceKeyframes <| Tile.baseSizeY * Tile.scale window


reachedLevel : Model -> Levels.Key
reachedLevel model =
    Scene.getContext model.scene
        |> .progress
        |> Progress.reachedLevel


currentLevel : Model -> Levels.Key
currentLevel model =
    model.scene
        |> (Scene.getContext >> .progress)
        |> Progress.currentLevel
        |> Maybe.withDefault Levels.empty


shouldIncrement : Context -> Bool
shouldIncrement context =
    not <| Progress.currentLevelComplete context.progress



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
    case model.scene of
        Hub _ ->
            Time.every 100 UpdateTimes

        _ ->
            Time.every 5000 UpdateTimes


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
        , loadingScreen <| Scene.getContext model.scene
        , menu model.scene
        , renderStage
            [ renderScene model.scene
            , renderBackrop model.backdrop
            ]
        , background
        ]


renderStage : List (List ( String, Html msg )) -> Html msg
renderStage =
    Keyed.node "div" [] << List.concat


renderBackrop : Maybe Scene -> List ( String, Html Msg )
renderBackrop =
    Maybe.map renderScene >> Maybe.withDefault []


renderScene : Scene -> List ( String, Html Msg )
renderScene scene =
    case scene of
        Hub model ->
            [ ( "hub", Hub.view model |> Html.map HubMsg ) ]

        Intro model ->
            [ ( "intro", Intro.view model |> Html.map IntroMsg ) ]

        Title model ->
            [ ( "title", Title.view model |> Html.map TitleMsg ) ]

        Level model ->
            [ ( "level", Level.view model |> Html.map LevelMsg ) ]

        Tutorial model ->
            [ ( "tutorial", Tutorial.view model |> Html.map TutorialMsg ) ]

        Summary model ->
            [ ( "summary", Summary.view model |> Html.map SummaryMsg ) ]

        Retry model ->
            [ ( "retry", Retry.view model |> Html.map RetryMsg ) ]

        Garden model ->
            [ ( "garden", Garden.view model |> Html.map GardenMsg ) ]



-- Menu


menu : Scene -> Html Msg
menu scene =
    let
        renderMenu =
            Menu.view
                { close = CloseMenu
                , open = OpenMenu
                , resetData = ResetData
                }
    in
    case scene of
        Title model ->
            renderMenu model.context TitleMsg Title.menuOptions

        Hub model ->
            renderMenu model.context HubMsg Hub.menuOptions

        Level model ->
            renderMenu model.context LevelMsg Level.menuOptions

        Garden model ->
            renderMenu model.context GardenMsg Garden.menuOptions

        _ ->
            Menu.fadeOut


background : Html msg
background =
    div
        [ style [ backgroundColor Color.lightYellow ]
        , class "fixed w-100 h-100 top-0 left-0 z-0"
        ]
        []
