module Scene.Intro exposing
    ( Model
    , Msg
    , getContext
    , init
    , update
    , updateContext
    , view
    )

import Context exposing (Context)
import Element exposing (..)
import Element.Background as Background
import Element.Layout as Layout
import Element.Palette as Palette
import Element.Scale as Scale
import Element.Text as Text
import Element.Transition as Transition
import Exit exposing (continue, exit)
import Html exposing (Html)
import Scene.Intro.DyingLandscape as DL
import Scene.Intro.GrowingSeeds as GS
import Scene.Intro.SunflowerMeadow as SM
import Utils.Delay exposing (sequence)
import Utils.Element as Element
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
    | SetBackground Color
    | SetText String
    | SetTextColor Color
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
    , background = Palette.transparent
    , text = "Our world is dying"
    , textColor = Palette.brownYellow
    , textVisible = False
    }


introSequence : Cmd Msg
introSequence =
    sequence
        [ ( 100, SetBackground Palette.green9 )
        , ( 1000, ShowDyingLandscape )
        , ( 4000, SetBackground Palette.lightGreyYellow )
        , ( 1000, ShowText )
        , ( 1000, KillEnvironment )
        , ( 2000, HideDyingLandscape )
        , ( 1000, HideText )
        , ( 1000, SetText "We must save our seeds" )
        , ( 500, SetBackground Palette.lightGold )
        , ( 500, ShowGrowingSeeds )
        , ( 1500, HideText )
        , ( 500, HideGrowingSeeds )
        , ( 0, SetTextColor Palette.white )
        , ( 500, SetText "To bloom again on a new world" )
        , ( 1500, InitRollingHills )
        , ( 100, ShowRollingHills )
        , ( 3000, BloomFlowers )
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

        SetBackground bg ->
            continue { model | background = bg } []

        SetTextColor color ->
            continue { model | textColor = color } []

        IntroComplete ->
            exit model



-- View


view : Model -> Html Msg
view model =
    Layout.view
        [ Background.color model.background
        , Transition.background 1500
        , behindContent (viewScene model)
        ]
        (column
            [ width fill
            , height fill
            , paddingXY 0 Scale.extraLarge
            ]
            [ viewText model ]
        )


viewText : Model -> Element msg
viewText model =
    Text.text
        [ Text.color model.textColor
        , Element.visibleIf model.textVisible
        , Transition.alpha 1000
        , Text.large
        , moveDown (vh model.context.window / 5)
        , centerX
        ]
        model.text



--div
--    [ style
--        [ background model.backdrop
--        , transitionAll 1500 []
--        ]
--    , class "fixed top-0 left-0 w-100 h-100 z-1"
--    ]
--    [ p
--        [ style
--            [ textOffsetTop model.context.window
--            , textOffsetBottom model.context.window
--            , color model.textColor
--            , transitionAll 1000 []
--            , showIf model.textVisible
--            ]
--        , class "tc f3 relative z-2"
--        ]
--        [ text model.text ]
--    , skipButton
--    , renderScene model
--    ]
--skipButton : Html Msg
--skipButton =
--    div [ class "fixed bottom-1 w-100 z-6 flex", style [ opacity 0.6 ] ]
--        [ p
--            [ class "ttu dib center pointer tracked-mega f6"
--            , style
--                [ color Color.white
--                , animation "fade-in" 1000 []
--                ]
--            , onClick IntroComplete
--            ]
--            [ text "skip" ]
--        ]
--
--


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
        DyingLandscape environment vis ->
            html (DL.view model.context.window environment vis)

        GrowingSeeds vis ->
            GS.view model.context.window vis

        SunflowerMeadow vis ->
            html (SM.view model.context.window vis)



--textOffsetTop : Window -> Style
--textOffsetTop window =
--    marginTop <| toFloat window.height / 5
--
--
--textOffsetBottom : Window -> Style
--textOffsetBottom window =
--    case Window.width window of
--        Window.Narrow ->
--            marginBottom 50
--
--        _ ->
--            marginBottom 60
