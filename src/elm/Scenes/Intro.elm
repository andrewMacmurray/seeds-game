module Scenes.Intro exposing
    ( Model
    , Msg
    , getContext
    , init
    , update
    , updateContext
    , view
    )

import Context exposing (Context)
import Css.Animation exposing (animation)
import Css.Color as Color
import Css.Style as Style exposing (..)
import Css.Transition exposing (transitionAll)
import Data.Window as Window exposing (Window)
import Exit exposing (continue, exit)
import Helpers.Delay exposing (sequence, trigger)
import Html exposing (..)
import Html.Attributes exposing (class, classList)
import Html.Events exposing (onClick)
import Scenes.Intro.DyingLandscape as DL
import Scenes.Intro.GrowingSeeds as GS
import Scenes.Intro.SunflowerMeadow as SM
import Task



-- Model


type alias Model =
    { context : Context
    , scene : Scene
    , backdrop : String
    , text : String
    , textColor : String
    , textVisible : Bool
    }


type Scene
    = DyingLandscape DL.Environment DL.State
    | GrowingSeeds GS.State
    | SunflowerMeadow SM.State


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



-- Context


getContext : Model -> Context
getContext model =
    model.context


updateContext : (Context -> Context) -> Model -> Model
updateContext f model =
    { model | context = f model.context }



-- Init


init : Context -> ( Model, Cmd Msg )
init context =
    ( initialState context
    , introSequence
    )


initialState : Context -> Model
initialState context =
    { context = context
    , scene = DyingLandscape DL.Alive DL.Hidden
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
        , ( 4000, SetBackdrop Color.lightGreyYellow )
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
        , ( 500, SetText "To bloom again on a new world" )
        , ( 1500, InitRollingHills )
        , ( 100, ShowRollingHills )
        , ( 500, SetBackdrop Color.meadowGreen )
        , ( 500, BloomFlowers )
        , ( 4000, HideText )
        , ( 1500, IntroComplete )
        ]



-- Update


update : Msg -> Model -> Exit.Status ( Model, Cmd Msg )
update msg model =
    case msg of
        ShowDyingLandscape ->
            continue { model | scene = DyingLandscape DL.Alive DL.Entering } []

        KillEnvironment ->
            continue { model | scene = DyingLandscape DL.Dead DL.Visible } []

        HideDyingLandscape ->
            continue { model | scene = DyingLandscape DL.Dead DL.Leaving } []

        ShowGrowingSeeds ->
            continue { model | scene = GrowingSeeds GS.Entering } []

        HideGrowingSeeds ->
            continue { model | scene = GrowingSeeds GS.Leaving } []

        InitRollingHills ->
            continue { model | scene = SunflowerMeadow SM.Hidden } []

        ShowRollingHills ->
            continue { model | scene = SunflowerMeadow SM.Entering } []

        BloomFlowers ->
            continue { model | scene = SunflowerMeadow SM.Blooming } []

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

        IntroComplete ->
            exit model



-- View


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
                [ textOffsetTop model.context.window
                , textOffsetBottom model.context.window
                , color model.textColor
                , transitionAll 1000 []
                , showIf model.textVisible
                ]
            , class "tc f3 relative z-2"
            ]
            [ text model.text ]
        , skipButton
        , renderScene model
        ]


skipButton : Html Msg
skipButton =
    div [ class "fixed bottom-1 w-100 z-6 flex", style [ opacity 0.6 ] ]
        [ p
            [ class "ttu dib center pointer tracked-mega f6"
            , style
                [ color Color.white
                , animation "fade-in" 1000 []
                ]
            , onClick IntroComplete
            ]
            [ text "skip" ]
        ]


renderScene : Model -> Html Msg
renderScene model =
    case model.scene of
        DyingLandscape environment vis ->
            DL.view model.context.window environment vis

        GrowingSeeds vis ->
            GS.view model.context.window vis

        SunflowerMeadow vis ->
            SM.view model.context.window vis


textOffsetTop : Window -> Style
textOffsetTop window =
    marginTop <| toFloat window.height / 5


textOffsetBottom : Window -> Style
textOffsetBottom window =
    case Window.width window of
        Window.Narrow ->
            marginBottom 50

        _ ->
            marginBottom 60
