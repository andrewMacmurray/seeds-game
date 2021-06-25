module Scene.Title exposing
    ( Destination(..)
    , Model
    , Msg
    , init
    , menuOptions
    , subscriptions
    , update
    , view
    )

import Context exposing (Context)
import Delay
import Element exposing (..)
import Element.Animations as Animations
import Element.Button as Button
import Element.Layout as Layout
import Element.Scale as Scale
import Element.Seed as Seed
import Element.Text as Text
import Exit exposing (continue, exitWith)
import Game.Level.Progress as Progress
import Html exposing (Html)
import Ports exposing (introMusicPlaying, playIntroMusic)
import Simple.Animation as Animation
import Utils.Animated as Animated
import Utils.Element exposing (verticalGap)
import Utils.Function exposing (apply)
import Utils.Update as Update
import View.Menu as Menu



-- Model


type alias Model =
    { context : Context
    , fade : FadeDirection
    }


type Msg
    = FadeSeeds
    | PlayIntro
    | IntroMusicPlaying
    | GoToIntro
    | GoToHub
    | GoToGarden


type FadeDirection
    = Appearing
    | Disappearing


type Destination
    = ToHub
    | ToIntro
    | ToGarden



-- Menu


menuOptions : List (Menu.Option Msg)
menuOptions =
    [ Menu.option GoToHub "Levels"
    , Menu.option GoToGarden "Garden"
    ]



-- Init


init : Context -> ( Model, Cmd Msg )
init context =
    ( initialState context, Cmd.none )


initialState : Context -> Model
initialState context =
    { context = context
    , fade = Appearing
    }



-- Update


update : Msg -> Model -> Exit.With Destination ( Model, Cmd Msg )
update msg model =
    case msg of
        FadeSeeds ->
            continue { model | fade = Disappearing } []

        PlayIntro ->
            continue (Update.withContext Context.disableMenu model) [ playIntroMusic () ]

        IntroMusicPlaying ->
            continue model
                [ Delay.sequence
                    [ ( 0, FadeSeeds )
                    , ( 2000, GoToIntro )
                    ]
                ]

        GoToIntro ->
            exitWith ToIntro model

        GoToHub ->
            exitWith ToHub model

        GoToGarden ->
            exitWith ToGarden model



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions _ =
    introMusicPlaying (always IntroMusicPlaying)



-- View


view : Model -> Html Msg
view model =
    Layout.view []
        (column [ height fill, width fill ]
            [ titleBanner model
            , verticalGap 1
            ]
        )


titleBanner : Model -> Element Msg
titleBanner model =
    el [ centerX, height fill, paddingXY Scale.medium 0 ]
        (column
            [ centerX
            , spacing (Scale.large + Scale.small)
            , alignBottom
            , moveDown 60
            ]
            [ seeds model
            , column [ centerX, spacing Scale.large ]
                [ titleText model
                , playButton model
                ]
            ]
        )


titleText : Model -> Element msg
titleText model =
    case model.fade of
        Appearing ->
            fadeIn { duration = 1000, delay = 500 } [ centerX ] titleText_

        Disappearing ->
            fadeOut { duration = 1000, delay = 0 } [ centerX ] titleText_


titleText_ : Element msg
titleText_ =
    Text.text
        [ Text.f3
        , Text.wideSpaced
        , centerX
        ]
        "seeds"


playButton : Model -> Element Msg
playButton model =
    case model.fade of
        Appearing ->
            fadeIn { duration = 800, delay = 2500 } [ centerX ] (playButton_ model)

        Disappearing ->
            fadeOut { duration = 1500, delay = 0 } [ centerX ] (playButton_ model)


playButton_ : Model -> Element Msg
playButton_ model =
    el [ centerX ]
        (Button.button [ Button.orange ]
            { label = "Play"
            , onClick = action model
            }
        )


action : Model -> Msg
action model =
    if Progress.isFirstPlay model.context.progress then
        PlayIntro

    else
        GoToHub


seeds : Model -> Element msg
seeds model =
    row
        [ spacing Scale.medium
        , height fill
        , width (fill |> maximum 400)
        , paddingXY Scale.medium 0
        ]
        (List.map3
            (fadeSeed model.fade)
            (seedEntranceDelays 500)
            (seedExitDelays 500)
            allSeeds
        )


allSeeds : List (Element msg)
allSeeds =
    List.map (apply Seed.fill)
        [ Seed.chrysanthemum
        , Seed.marigold
        , Seed.sunflower
        , Seed.lupin
        , Seed.rose
        ]


seedEntranceDelays : Int -> List Int
seedEntranceDelays interval =
    List.map ((*) interval) [ 3, 2, 1, 2, 3 ]


seedExitDelays : Int -> List Int
seedExitDelays interval =
    List.map ((*) interval) [ 0, 1, 2, 1, 0 ]


fadeSeed : FadeDirection -> Int -> Int -> Element msg -> Element msg
fadeSeed direction entranceDelay exitDelay seed_ =
    case direction of
        Appearing ->
            fadeIn { delay = entranceDelay, duration = 1000 }
                [ centerX
                , width fill
                ]
                seed_

        Disappearing ->
            fadeOut { delay = exitDelay, duration = 1000 }
                [ centerX
                , width fill
                ]
                seed_


type alias Fade =
    { delay : Animation.Millis
    , duration : Animation.Millis
    }


fadeIn : Fade -> List (Attribute msg) -> Element msg -> Element msg
fadeIn fade =
    Animated.el
        (Animations.fadeIn fade.duration
            [ Animation.linear
            , Animation.delay fade.delay
            ]
        )


fadeOut : Fade -> List (Attribute msg) -> Element msg -> Element msg
fadeOut fade =
    Animated.el
        (Animations.fadeOut fade.duration
            [ Animation.linear
            , Animation.delay fade.delay
            ]
        )
