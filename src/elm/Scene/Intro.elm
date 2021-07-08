module Scene.Intro exposing
    ( Model
    , Msg
    , init
    , update
    , view
    )

import Context exposing (Context)
import Delay
import Element exposing (..)
import Element.Background as Background
import Element.Events exposing (onClick)
import Element.Layout as Layout
import Element.Palette as Palette
import Element.Scale as Scale
import Element.Text as Text
import Exit exposing (continue, exit)
import Scene.Intro.DyingLandscape as DL
import Scene.Intro.GrowingSeeds as GS
import Scene.Intro.SunflowerMeadow as SM
import Utils.Element as Element
import Utils.Transition as Transition
import Window exposing (vh)



-- Model


type alias Model =
    { context : Context
    , scene : Scene
    , background : Color
    , text : String
    , textColor : Color
    , textVisible : Bool
    }


type Scene
    = DyingLandscape DL.State
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
    | SetBackground Color
    | SetText String
    | SetTextColor Color
    | ShowText
    | HideText
    | KillEnvironment
    | IntroComplete



-- Init


init : Context -> ( Model, Cmd Msg )
init context =
    ( initialState context
    , introSequence
    )


initialState : Context -> Model
initialState context =
    { context = context
    , scene = DyingLandscape DL.hidden
    , background = Palette.background1_
    , text = "Our world is dying"
    , textColor = Palette.yellow1
    , textVisible = False
    }


introSequence : Cmd Msg
introSequence =
    Delay.sequence
        [ ( 100, SetBackground Palette.green10 )
        , ( 1000, ShowDyingLandscape )
        , ( 4000, SetBackground Palette.lightGreyYellow )
        , ( 1000, ShowText )
        , ( 1000, KillEnvironment )

        --, ( 2000, HideDyingLandscape )
        --, ( 1000, HideText )
        --, ( 1000, SetText "We must save our seeds" )
        --, ( 500, SetBackground Palette.lightGold )
        --, ( 500, ShowGrowingSeeds )
        --, ( 1500, HideText )
        --, ( 500, HideGrowingSeeds )
        --, ( 0, SetTextColor Palette.white )
        --, ( 500, SetText "To bloom again on a new world" )
        --, ( 1500, InitRollingHills )
        --, ( 100, ShowRollingHills )
        --, ( 3000, BloomFlowers )
        --, ( 4000, HideText )
        --, ( 1500, IntroComplete )
        ]



-- Update


update : Msg -> Model -> Exit.Status ( Model, Cmd Msg )
update msg model =
    case msg of
        ShowDyingLandscape ->
            continue { model | scene = DyingLandscape DL.alive } []

        KillEnvironment ->
            continue { model | scene = DyingLandscape DL.dead } []

        HideDyingLandscape ->
            continue { model | scene = DyingLandscape DL.leaving } []

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

        SetBackground bg ->
            continue { model | background = bg } []

        SetTextColor color ->
            continue { model | textColor = color } []

        IntroComplete ->
            exit model



-- View


view : Model -> Layout.Scene Msg
view model =
    Layout.scene
        [ Background.color model.background
        , Transition.background 1500
        , behindContent (viewScene model)
        ]
        (column
            [ width fill
            , height fill
            ]
            [ sceneText model
            , skipButton
            ]
        )


sceneText : Model -> Element msg
sceneText model =
    Text.text
        [ Text.color model.textColor
        , Element.visibleIf model.textVisible
        , Transition.alpha 1000
        , Text.f3
        , moveDown (vh model.context.window / 5)
        , centerX
        ]
        model.text


skipButton : Element Msg
skipButton =
    Text.text
        [ padding Scale.large
        , Text.white
        , alignBottom
        , centerX
        , onClick IntroComplete
        , pointer
        , Text.spaced
        ]
        "skip"


viewScene : Model -> Element Msg
viewScene model =
    el
        [ centerX
        , centerY
        , width fill
        ]
        (viewScene_ model)


viewScene_ : Model -> Element Msg
viewScene_ model =
    case model.scene of
        DyingLandscape state ->
            html (DL.view model.context.window state)

        GrowingSeeds state ->
            GS.view model.context.window state

        SunflowerMeadow state ->
            html (SM.view model.context.window state)
