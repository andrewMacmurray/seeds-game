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
import Element.Button.Cancel as Cancel
import Element.Layout as Layout
import Element.Scale as Scale
import Element.Text as Text
import Exit exposing (continue, exitWith)
import Game.Lives as Lives
import Html exposing (..)
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
    Layout.fadeIn
        { duration = 1000
        , attributes = []
        }
        (column
            [ centerX
            , centerY
            , spacing Scale.large
            , moveUp 20
            ]
            [ el [] (html (Lives.view model.lives))
            , tryAgainText
            , Animated.el (bounceInButton model.window) [ centerX ] tryAgain
            ]
        )


tryAgainText : Element msg
tryAgainText =
    column
        [ centerX
        , spacing Scale.medium
        ]
        [ largeText "You lost a life..."
        , Animated.el fadeInText [ centerX ] (largeText "But don't feel disheartened")
        ]


tryAgain : Element Msg
tryAgain =
    Cancel.button
        { onCancel = ReturnToHubClicked
        , onClick = RestartLevelClicked
        , confirmText = "Try Again?"
        }


fadeInText : Animation
fadeInText =
    Animations.fadeIn 1000 [ Animation.delay 2500 ]


bounceInButton : Window -> Animation
bounceInButton window =
    Animation.fromTo
        { duration = 600
        , options = [ Animation.springy1, Animation.delay 3000 ]
        }
        [ P.y (vh window / 2 - 20) ]
        [ P.y 0 ]



-- Text


largeText : String -> Element msg
largeText =
    Text.text [ centerX, Text.large ]
