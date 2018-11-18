module Scenes.Retry exposing
    ( Model
    , Msg
    , getShared
    , init
    , update
    , updateShared
    , view
    )

import Css.Animation exposing (animation, delay, ease, linear)
import Css.Color as Color
import Css.Style as Style exposing (..)
import Css.Transform exposing (..)
import Css.Unit exposing (pc)
import Data.Lives as Lives
import Data.Transit exposing (Transit(..))
import Exit exposing (continue, exitTo)
import Helpers.Delay exposing (after)
import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Shared
import Views.Lives exposing (renderLivesLeft)



-- Model


type alias Model =
    Shared.Data


type Msg
    = DecrementLives
    | RestartLevel
    | ReturnToHub



-- Shared


getShared : Model -> Shared.Data
getShared =
    identity


updateShared : (Shared.Data -> Shared.Data) -> Model -> Model
updateShared =
    identity



-- Init


init : Shared.Data -> ( Model, Cmd Msg )
init shared =
    ( shared
    , after 1000 DecrementLives
    )



-- Update


update : Msg -> Model -> Exit.ToScene ( Model, Cmd Msg )
update msg model =
    case msg of
        DecrementLives ->
            continue (updateShared Shared.decrementLife model) []

        RestartLevel ->
            exitTo Exit.ToLevel model

        ReturnToHub ->
            exitTo Exit.ToHub model



-- View


view : Model -> Html Msg
view model =
    div
        [ style
            [ height <| toFloat model.window.height
            , background Color.washedYellow
            , animation "fade-in" 1000 [ linear ]
            ]
        , class "fixed z-5 flex justify-center items-center w-100 top-0 left-0"
        ]
        [ div
            [ style [ Style.property "margin-top" <| pc -8 ]
            , class "tc"
            ]
            [ div [] <| renderLivesLeft <| lifeState model
            , div [ style [ color Color.darkYellow ] ]
                [ p [ class "mt3" ] [ text "You lost a life ..." ]
                , p
                    [ style [ animation "fade-in" 1000 [ delay 2500, ease ] ]
                    , class "o-0"
                    ]
                    [ text "But don't feel disheartened" ]
                ]
            , div
                [ style
                    [ animation "bounce-up" 1500 [ delay 3000, linear ]
                    , transform [ translate 0 (toFloat <| model.window.height + 100) ]
                    ]
                ]
                [ tryAgain model ]
            ]
        ]


lifeState : Shared.Data -> Transit Int
lifeState model =
    model.lives
        |> Lives.remaining
        |> Transitioning


tryAgain : Model -> Html Msg
tryAgain model =
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
