module Scene.Retry exposing
    ( Destination(..)
    , Model
    , Msg
    , getContext
    , init
    , update
    , updateContext
    , view
    )

import Context exposing (Context)
import Element exposing (..)
import Element.Animation as Animation
import Element.Animations as Animations
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Layout as Layout
import Element.Palette as Palette
import Element.Scale as Scale exposing (corners)
import Element.Text as Text
import Exit exposing (continue, exitWith)
import Html exposing (..)
import Lives
import Simple.Animation as Animation exposing (Animation)
import Simple.Animation.Property as P
import Utils.Animated as Animated
import Utils.Delay exposing (after)
import Window exposing (Window, vh)



-- Model


type alias Model =
    Context


type Msg
    = DecrementLives
    | RestartLevelClicked
    | ReturnToHubClicked


type Destination
    = ToLevel
    | ToHub



-- Context


getContext : Model -> Context
getContext =
    identity


updateContext : (Context -> Context) -> Model -> Model
updateContext =
    identity



-- Init


init : Context -> ( Model, Cmd Msg )
init context =
    ( context
    , after 1000 DecrementLives
    )



-- Update


update : Msg -> Model -> Exit.With Destination ( Model, Cmd Msg )
update msg model =
    case msg of
        DecrementLives ->
            continue (updateContext Context.decrementLife model) []

        RestartLevelClicked ->
            exitWith ToLevel model

        ReturnToHubClicked ->
            exitWith ToHub model



-- View


view : Model -> Html Msg
view model =
    Layout.view
        [ Palette.background2
        ]
        (Animated.column fadeInScene
            [ centerX
            , centerY
            , spacing Scale.large
            , moveUp 20
            ]
            [ el [] (html (Lives.view model.lives))
            , column
                [ centerX
                , spacing Scale.medium
                ]
                [ Text.text [ centerX, Text.large ] "You lost a life..."
                , Animated.el fadeInText [ centerX ] (Text.text [ Text.large ] "But don't feel disheartened")
                ]
            , Animated.el (bounceInButton model.window) [ centerX ] tryAgain
            ]
        )


fadeInScene : Animation
fadeInScene =
    Animations.fadeIn 1000 [ Animation.linear ]


fadeInText : Animation
fadeInText =
    Animations.fadeIn 1000 [ Animation.delay 2500 ]


bounceInButton : Window -> Animation
bounceInButton window =
    Animation.fromTo
        { duration = 600
        , options = [ Animation.springy, Animation.delay 3000 ]
        }
        [ P.y (vh window / 2 - 20) ]
        [ P.y 0 ]


tryAgain : Element Msg
tryAgain =
    row []
        [ el
            [ onClick ReturnToHubClicked
            , Background.color Palette.green6
            , pointer
            , paddingEach
                { left = Scale.medium + Scale.small
                , right = Scale.medium
                , top = Scale.medium
                , bottom = Scale.medium
                }
            , Border.roundEach { corners | bottomLeft = 40, topLeft = 40 }
            ]
            (Text.text [ Text.color Palette.white ] "X")
        , el
            [ onClick RestartLevelClicked
            , pointer
            , Background.color Palette.green2
            , paddingEach
                { left = Scale.medium
                , right = Scale.medium + Scale.small
                , top = Scale.medium
                , bottom = Scale.medium
                }
            , Border.roundEach { corners | bottomRight = 40, topRight = 40 }
            ]
            (Text.text [ Text.color Palette.white ] "Try Again?")
        ]
