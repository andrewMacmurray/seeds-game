module Scenes.Intro exposing
    ( Model
    , Msg
    , getShared
    , init
    , update
    , updateShared
    , view
    )

import Css.Color as Color
import Css.Style as Style exposing (..)
import Css.Transition exposing (transitionAll)
import Data.Visibility exposing (..)
import Exit exposing (continue, exit)
import Helpers.Delay exposing (sequence, trigger)
import Html exposing (..)
import Html.Attributes exposing (class, classList)
import Shared exposing (Window)
import Task
import Views.Intro.DyingLandscape exposing (Environment(..), dyingLandscape)
import Views.Intro.GrowingSeeds exposing (growingSeeds)
import Views.Intro.RollingHills exposing (rollingHills)



-- MODEL


type alias Model =
    { shared : Shared.Data
    , scene : Scene
    , backdrop : String
    , text : String
    , textColor : String
    , textVisible : Bool
    }


type Scene
    = DyingLandscape Environment Visibility
    | GrowingSeeds Visibility
    | RollingHills Visibility


type Msg
    = ShowDyingLandscape
    | HideDyingLandscape
    | ShowGrowingSeeds
    | HideGrowingSeeds
    | InitRollingHills
    | ShowRollingHills
    | BloomFlowers
    | SetBackdrop String
    | SetText String
    | SetTextColor String
    | ShowText
    | HideText
    | KillEnvironment
    | IntroComplete



-- Shared


getShared : Model -> Shared.Data
getShared model =
    model.shared


updateShared : (Shared.Data -> Shared.Data) -> Model -> Model
updateShared f model =
    { model | shared = f model.shared }



-- INIT


init : Shared.Data -> ( Model, Cmd Msg )
init shared =
    ( initialState shared
    , introSequence
    )


initialState : Shared.Data -> Model
initialState shared =
    { shared = shared
    , scene = DyingLandscape Alive Hidden
    , backdrop = Color.transparent
    , text = "Our world is dying"
    , textColor = Color.brownYellow
    , textVisible = False
    }


introSequence : Cmd Msg
introSequence =
    sequence
        [ ( 100, SetBackdrop Color.skyGreen )
        , ( 1000, ShowDyingLandscape )
        , ( 4000, SetBackdrop Color.skyYellow )
        , ( 1000, ShowText )
        , ( 1000, KillEnvironment )
        , ( 2000, HideDyingLandscape )
        , ( 1000, HideText )
        , ( 1000, SetText "We must save our seeds" )
        , ( 500, SetBackdrop Color.lightGold )
        , ( 500, ShowGrowingSeeds )
        , ( 1500, HideText )
        , ( 500, HideGrowingSeeds )
        , ( 0, SetTextColor Color.white )
        , ( 500, SetText "So they may bloom again on a new world" )
        , ( 1500, InitRollingHills )
        , ( 100, ShowRollingHills )
        , ( 500, SetBackdrop Color.meadowGreen )
        , ( 500, BloomFlowers )
        , ( 4000, HideText )
        , ( 1500, IntroComplete )
        ]



-- UPDATE


update : Msg -> Model -> Exit.Status ( Model, Cmd Msg )
update msg model =
    case msg of
        ShowDyingLandscape ->
            continue { model | scene = DyingLandscape Alive Entering } []

        HideDyingLandscape ->
            continue { model | scene = DyingLandscape Dead Leaving } []

        ShowGrowingSeeds ->
            continue { model | scene = GrowingSeeds Entering } []

        HideGrowingSeeds ->
            continue { model | scene = GrowingSeeds Leaving } []

        ShowRollingHills ->
            continue { model | scene = RollingHills Entering } []

        InitRollingHills ->
            continue { model | scene = RollingHills Hidden } []

        BloomFlowers ->
            continue { model | scene = RollingHills Visible } []

        ShowText ->
            continue { model | textVisible = True } []

        SetText text ->
            continue { model | text = text, textVisible = True } []

        HideText ->
            continue { model | textVisible = False } []

        SetBackdrop bg ->
            continue { model | backdrop = bg } []

        SetTextColor color ->
            continue { model | textColor = color } []

        KillEnvironment ->
            continue { model | scene = DyingLandscape Dead Visible } []

        IntroComplete ->
            exit model



-- VIEW


view : Model -> Html Msg
view model =
    div
        [ style
            [ background model.backdrop
            , transitionAll 1500 []
            ]
        , class "fixed top-0 left-0 w-100 h-100 z-1"
        ]
        [ p
            [ style
                [ textOffset model.shared.window
                , color model.textColor
                , transitionAll 1000 []
                ]
            , showIf model.textVisible
            , class "tc f5 f3-ns relative z-2"
            ]
            [ text model.text ]
        , renderScene model
        ]


renderScene : Model -> Html Msg
renderScene model =
    case model.scene of
        DyingLandscape environment vis ->
            dyingLandscape environment vis

        GrowingSeeds vis ->
            growingSeeds model.shared.window vis

        RollingHills vis ->
            rollingHills model.shared.window vis


textOffset : Window -> Style
textOffset window =
    marginTop <| toFloat <| (window.height // 2) - 120
