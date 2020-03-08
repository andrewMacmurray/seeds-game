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
import Css.Animation
import Css.Color as Color
import Css.Style as Style exposing (..)
import Css.Transform
import Css.Unit exposing (pc)
import Exit exposing (continue, exitWith)
import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Lives
import Utils.Delay exposing (after)



-- Model


type alias Model =
    Context


type Msg
    = DecrementLives
    | RestartLevel
    | ReturnToHub


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

        RestartLevel ->
            exitWith ToLevel model

        ReturnToHub ->
            exitWith ToHub model



-- View


view : Model -> Html Msg
view model =
    div
        [ style
            [ height <| toFloat model.window.height
            , background Color.washedYellow
            , Css.Animation.animation "fade-in" 1000 [ Css.Animation.linear ]
            ]
        , class "fixed z-5 flex justify-center items-center w-100 top-0 left-0"
        ]
        [ div
            [ style [ Style.property "margin-top" <| pc -8 ]
            , class "tc"
            ]
            [ div [] <| Lives.view model.lives
            , div [ style [ color Color.darkYellow ] ]
                [ p [ class "mt3" ] [ text "You lost a life ..." ]
                , p
                    [ style [ Css.Animation.animation "fade-in" 1000 [ Css.Animation.delay 2500, Css.Animation.ease ] ]
                    , class "o-0"
                    ]
                    [ text "But don't feel disheartened" ]
                ]
            , div
                [ style
                    [ Css.Animation.animation "bounce-up" 1500 [ Css.Animation.delay 3000, Css.Animation.linear ]
                    , transform [ Css.Transform.translate 0 (toFloat <| model.window.height + 100) ]
                    ]
                ]
                [ tryAgain model ]
            ]
        ]


tryAgain : Model -> Html Msg
tryAgain _ =
    div [ style [ marginTop 50 ], class "pointer" ]
        [ div
            [ style
                [ background Color.lightGreen
                , color Color.white
                , paddingLeft 25
                , paddingRight 20
                , paddingTop 15
                , paddingBottom 15
                , leftPill
                ]
            , class "dib"
            , onClick ReturnToHub
            ]
            [ p [ class "ma0" ] [ text "X" ] ]
        , div
            [ style
                [ background Color.mediumGreen
                , color Color.white
                , paddingLeft 25
                , paddingRight 20
                , paddingTop 15
                , paddingBottom 15
                , rightPill
                ]
            , class "dib"
            , onClick RestartLevel
            ]
            [ p [ class "ma0" ] [ text "Try again?" ] ]
        ]
