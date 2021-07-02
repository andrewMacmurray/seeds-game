module Main exposing (main)

import Browser
import Browser.Events as Browser
import Context exposing (Context)
import Delay
import Element.Layout as Layout
import Element.Loading as LoadingScreen exposing (Screen)
import Element.Menu as Menu
import Exit
import Game.Config.Level as Level
import Game.Config.World as Worlds
import Game.Level.Progress as Progress exposing (Progress)
import Game.Lives as Lives
import Html exposing (Html)
import Ports.Audio as Audio
import Ports.Cache as Cache
import Ports.Swipe as Swipe
import Scene.Garden as Garden
import Scene.Hub as Hub
import Scene.Intro as Intro
import Scene.Level as Level
import Scene.Retry as Retry
import Scene.Summary as Summary
import Scene.Title as Title
import Time exposing (millisToPosix)
import Utils.Update as Update exposing (andCmd, updateModel, updateWith)
import Window exposing (Window)



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
    , progress : Maybe Level.Cache
    , randomMessageIndex : Int
    , window : Window
    }


type alias Model =
    { scene : Scene
    , backdrop : Maybe Scene
    }


type Scene
    = Title Title.Model
    | Intro Intro.Model
    | Hub Hub.Model
    | Level Level.Model
    | Retry Retry.Model
    | Summary Summary.Model
    | Garden Garden.Model


type Msg
    = TitleMsg Title.Msg
    | IntroMsg Intro.Msg
    | HubMsg Hub.Msg
    | LevelMsg Level.Msg
    | RetryMsg Retry.Msg
    | SummaryMsg Summary.Msg
    | GardenMsg Garden.Msg
    | InitIntro
    | InitHub Level.Id
    | InitLevel Level.LevelConfig
    | InitRetry
    | InitSummary
    | InitGarden
    | ShowLoadingScreen
    | HideLoadingScreen
    | OpenMenuClicked
    | CloseMenuClicked
    | ScreenSwipedRight
    | LoadingScreenGenerated Screen
    | ResetDataClicked
    | WindowSize Int Int
    | UpdateLives Time.Posix
    | GoToHub Level.Id



-- Init


init : Flags -> ( Model, Cmd Msg )
init flags =
    initialContext flags
        |> Title.init
        |> updateWith TitleMsg initialState


initialState : Title.Model -> Model
initialState titleModel =
    { scene = Title titleModel
    , backdrop = Nothing
    }


initialContext : Flags -> Context
initialContext flags =
    { window = flags.window
    , loading = LoadingScreen.hidden
    , progress = Progress.init flags.progress
    , lives = Lives.init (millisToPosix flags.now) flags.lives
    , successMessageIndex = flags.randomMessageIndex
    , menu = Menu.closed
    }



-- Context


getContext : Model -> Context
getContext =
    .scene >> getContext_


getContext_ : Scene -> Context
getContext_ scene =
    case scene of
        Title model_ ->
            Update.context model_

        Intro model_ ->
            Update.context model_

        Hub model_ ->
            Update.context model_

        Level model_ ->
            Update.context model_

        Retry model_ ->
            Update.context model_

        Summary model_ ->
            Update.context model_

        Garden model_ ->
            Update.context model_


updateContext : (Context -> Context) -> Model -> Model
updateContext toContext model =
    { model | scene = updateContext_ toContext model.scene }


updateContext_ : (Context -> Context) -> Scene -> Scene
updateContext_ toContext scene =
    case scene of
        Title model ->
            Title (Update.withContext toContext model)

        Intro model ->
            Intro (Update.withContext toContext model)

        Hub model ->
            Hub (Update.withContext toContext model)

        Level model ->
            Level (Update.withContext toContext model)

        Retry model ->
            Retry (Update.withContext toContext model)

        Summary model ->
            Summary (Update.withContext toContext model)

        Garden model ->
            Garden (Update.withContext toContext model)



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

        ( InitLevel level, _, _ ) ->
            initLevel level model

        ( InitRetry, _, _ ) ->
            initRetry model

        ( InitSummary, _, _ ) ->
            initSummary model

        ( InitGarden, _, _ ) ->
            initGarden model

        ( ShowLoadingScreen, _, _ ) ->
            ( updateContext Context.closeMenu model
            , LoadingScreen.generate LoadingScreenGenerated
            )

        ( LoadingScreenGenerated screen, _, _ ) ->
            ( updateContext (Context.showLoadingScreen screen) model, Cmd.none )

        ( HideLoadingScreen, _, _ ) ->
            ( updateContext Context.hideLoadingScreen model, Cmd.none )

        ( OpenMenuClicked, _, _ ) ->
            ( updateContext Context.openMenu model, Cmd.none )

        ( CloseMenuClicked, _, _ ) ->
            ( updateContext Context.closeMenu model, Cmd.none )

        ( ScreenSwipedRight, _, _ ) ->
            ( updateContext Context.closeMenu model, Cmd.none )

        ( GoToHub level, _, _ ) ->
            ( model, withLoadingScreen (InitHub level) )

        ( ResetDataClicked, _, _ ) ->
            ( model, Cache.clear )

        ( WindowSize width height, _, _ ) ->
            ( updateContext (Context.setWindow width height) model
            , Cmd.none
            )

        ( UpdateLives now, _, _ ) ->
            updateLives now model

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
            ( model, Update.trigger InitIntro )

        Title.ToGarden ->
            ( model, goToGarden )



-- Intro


initIntro : Model -> ( Model, Cmd Msg )
initIntro =
    initScene Intro IntroMsg Intro.init >> closeMenu


updateIntro : Intro.Msg -> Intro.Model -> Model -> ( Model, Cmd Msg )
updateIntro =
    updateScene Intro IntroMsg Intro.update |> Exit.onExit exitIntro


exitIntro : Model -> () -> ( Model, Cmd Msg )
exitIntro model _ =
    ( model
    , Cmd.batch
        [ goToHubReachedLevel model
        , Audio.fadeOut
        ]
    )



-- Hub


initHub : Level.Id -> Model -> ( Model, Cmd Msg )
initHub level =
    initScene Hub HubMsg (Hub.init level) >> closeMenu


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


handleStartLevel : Model -> Level.Id -> ( Model, Cmd Msg )
handleStartLevel model level =
    ( model, withLoadingScreen (InitLevel (Worlds.levelConfig level)) )



-- Level


initLevel : Level.LevelConfig -> Model -> ( Model, Cmd Msg )
initLevel config =
    initScene Level LevelMsg (Level.init config) >> closeMenu


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
            levelLose model

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
    if shouldIncrement (getContext model) then
        ( model, Update.trigger InitSummary )

    else
        ( model, goToHubCurrentLevel model )


levelLose : Model -> ( Model, Cmd Msg )
levelLose model =
    if livesRemaining model == 1 then
        ( updateContext Context.decrementLife model, goToHubCurrentLevel model )

    else
        ( model, Update.trigger InitRetry )



-- Retry


initRetry : Model -> ( Model, Cmd Msg )
initRetry =
    copyCurrentSceneToBackdrop
        >> initScene Retry RetryMsg Retry.init
        >> closeMenu


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
    copyCurrentSceneToBackdrop
        >> initScene Summary SummaryMsg Summary.init
        >> closeMenu


updateSummary : Summary.Msg -> Summary.Model -> Model -> ( Model, Cmd Msg )
updateSummary =
    updateScene Summary SummaryMsg Summary.update |> Exit.onExit exitSummary


exitSummary : Model -> Summary.Destination -> ( Model, Cmd Msg )
exitSummary model destination =
    case destination of
        Summary.ToHub ->
            ( clearBackdrop model, goToHubReachedLevel model )

        Summary.ToGarden ->
            ( clearBackdrop model, Update.trigger InitGarden )



-- Garden


initGarden : Model -> ( Model, Cmd Msg )
initGarden =
    initScene Garden GardenMsg Garden.init >> closeMenu


updateGarden : Garden.Msg -> Garden.Model -> Model -> ( Model, Cmd Msg )
updateGarden =
    updateScene Garden GardenMsg Garden.update |> Exit.onExit exitGarden


exitGarden : Model -> () -> ( Model, Cmd Msg )
exitGarden model _ =
    ( model, goToHubReachedLevel model )



-- Util


initScene :
    (subModel -> Scene)
    -> (subMsg -> msg)
    -> (Context -> ( subModel, Cmd subMsg ))
    -> Model
    -> ( Model, Cmd msg )
initScene =
    load asForeground


updateScene :
    (subModel -> Scene)
    -> (subMsg -> msg)
    -> (subMsg -> subModel -> Exit.With payload ( subModel, Cmd subMsg ))
    -> Exit.Handle payload subMsg subModel Model msg
updateScene toScene =
    Exit.handle (updateSceneModel toScene asForeground)


updateBackdrop :
    (subModel -> Scene)
    -> (subMsg -> msg)
    -> (subMsg -> subModel -> Exit.With payload ( subModel, Cmd subMsg ))
    -> Exit.Handle payload subMsg subModel Model msg
updateBackdrop toScene =
    Exit.handle (updateSceneModel toScene asBackdrop)


load :
    (Model -> Scene -> Model)
    -> (subModel -> Scene)
    -> (subMsg -> msg)
    -> (Context -> ( subModel, Cmd subMsg ))
    -> Model
    -> ( Model, Cmd msg )
load toModel toScene msg initScene_ model =
    getContext model
        |> Context.closeMenu
        |> initScene_
        |> updateWith msg (toScene >> toModel model)


updateSceneModel : (subModel -> Scene) -> (Model -> Scene -> Model) -> (subModel -> Model -> Model)
updateSceneModel toScene toModel sceneModel model =
    toModel model (toScene sceneModel)


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



-- Misc


withLoadingScreen : Msg -> Cmd Msg
withLoadingScreen msg =
    Delay.sequence
        [ ( 0, ShowLoadingScreen )
        , ( 1000, msg )
        , ( 1500, HideLoadingScreen )
        ]


goToGarden : Cmd Msg
goToGarden =
    Delay.sequence
        [ ( 0, ShowLoadingScreen )
        , ( 2500, HideLoadingScreen )
        , ( 0, InitGarden )
        ]


reloadCurrentLevel : Model -> Cmd Msg
reloadCurrentLevel =
    withLoadingScreen << InitLevel << Worlds.levelConfig << currentLevel


goToHubCurrentLevel : Model -> Cmd Msg
goToHubCurrentLevel =
    Update.trigger << GoToHub << currentLevel


goToHubReachedLevel : Model -> Cmd Msg
goToHubReachedLevel =
    Update.trigger << GoToHub << reachedLevel


updateLives : Time.Posix -> Model -> ( Model, Cmd Msg )
updateLives now =
    updateContext (Context.updateLives now) >> andCmd saveCurrentLives


closeMenu : ( Model, Cmd msg ) -> ( Model, Cmd msg )
closeMenu =
    updateModel (updateContext Context.closeMenu)


saveCurrentLives : Model -> Cmd Msg
saveCurrentLives =
    getContext >> Context.saveCurrentLives


livesRemaining : Model -> Int
livesRemaining =
    getContext >> .lives >> Lives.remaining


reachedLevel : Model -> Level.Id
reachedLevel =
    getContext >> .progress >> Progress.reachedLevel


currentLevel : Model -> Level.Id
currentLevel =
    getContext >> .progress >> currentLevelWithDefault


currentLevelWithDefault : Progress -> Level.Id
currentLevelWithDefault progress =
    progress
        |> Progress.currentLevel
        |> Maybe.withDefault (Progress.reachedLevel progress)


shouldIncrement : Context -> Bool
shouldIncrement context =
    Progress.currentLevelComplete context.progress == Just False



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Browser.onResize WindowSize
        , handleSwipeRight
        , updateLivesSubscription model
        , sceneSubscriptions model
        ]


updateLivesSubscription : Model -> Sub Msg
updateLivesSubscription model =
    case model.scene of
        Hub _ ->
            Time.every 100 UpdateLives

        _ ->
            Time.every 5000 UpdateLives


sceneSubscriptions : Model -> Sub Msg
sceneSubscriptions model =
    case model.scene of
        Title titleModel ->
            Sub.map TitleMsg (Title.subscriptions titleModel)

        _ ->
            Sub.none


handleSwipeRight : Sub Msg
handleSwipeRight =
    Swipe.onRight ScreenSwipedRight



-- View


view : Model -> Html Msg
view model =
    Layout.view
        { menu = viewMenu model
        , loading = viewLoading model
        , scene = viewScene model.scene
        , backdrop = viewBackdrop model.backdrop
        }


viewBackdrop : Maybe Scene -> Maybe ( String, Layout.Scene Msg )
viewBackdrop =
    Maybe.map viewScene


viewScene : Scene -> ( String, Layout.Scene Msg )
viewScene scene =
    case scene of
        Hub model ->
            ( "hub", Layout.map HubMsg (Hub.view model) )

        Intro model ->
            ( "intro", Layout.map IntroMsg (Intro.view model) )

        Title model ->
            ( "title", Layout.map TitleMsg (Title.view model) )

        Level model ->
            ( "level", Layout.map LevelMsg (Level.view model) )

        Summary model ->
            ( "summary", Layout.map SummaryMsg (Summary.view model) )

        Retry model ->
            ( "retry", Layout.map RetryMsg (Retry.view model) )

        Garden model ->
            ( "garden", Layout.map GardenMsg (Garden.view model) )



-- Loading


viewLoading : Model -> Layout.Overlay msg
viewLoading model =
    loading (getContext model)


loading : Context -> Layout.Overlay msg
loading context =
    LoadingScreen.view
        { progress = context.progress
        , loading = context.loading
        }



-- Menu


viewMenu : Model -> Layout.Overlay Msg
viewMenu model =
    sceneMenu model.scene (getContext model)


sceneMenu : Scene -> Menu.Model model -> Layout.Overlay Msg
sceneMenu scene =
    case scene of
        Title _ ->
            menu_ TitleMsg Title.menuOptions

        Hub _ ->
            menu_ HubMsg Hub.menuOptions

        Level model ->
            menu_ LevelMsg (Level.menuOptions model)

        Garden _ ->
            menu_ GardenMsg Garden.menuOptions

        _ ->
            always Menu.hidden


menu_ : (sceneMsg -> Msg) -> List (Menu.Option sceneMsg) -> Menu.Model model -> Layout.Overlay Msg
menu_ =
    Menu.view
        { onClose = CloseMenuClicked
        , onOpen = OpenMenuClicked
        , onReset = ResetDataClicked
        }
