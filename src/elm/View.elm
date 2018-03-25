module View exposing (..)

import Config.Animations exposing (internalAnimations)
import Config.Color exposing (darkYellow)
import Helpers.Css.Style exposing (color)
import Helpers.Html exposing (embeddedStyle)
import Html exposing (..)
import Html.Attributes exposing (class, style)
import Html.Events exposing (onClick)
import Html.Keyed as K
import Scenes.Hub.View exposing (hubView)
import Scenes.Level.View exposing (levelView)
import Scenes.Retry.View exposing (retryView)
import Scenes.Summary.View exposing (summaryView)
import Scenes.Title.View exposing (titleView)
import Scenes.Tutorial.View exposing (tutorialView)
import Types exposing (Backdrop(..), Model, Msg(..), Scene(..))
import Views.Backdrop exposing (backdrop)
import Views.Loading exposing (loadingScreen)


view : Model -> Html Msg
view model =
    div []
        [ embeddedAnimations model.xAnimations
        , reset
        , loadingScreen model
        , renderScene model
        , backdrop
        ]


embeddedAnimations : String -> Html msg
embeddedAnimations externalanimations =
    div []
        [ embeddedStyle externalanimations
        , internalAnimations
        ]


renderScene : Model -> Html Msg
renderScene model =
    let
        kd =
            K.node "div" []
    in
        case model.scene of
            Hub ->
                kd [ ( "hub", hubView model ) ]

            Title ->
                kd [ ( "title", titleView model ) ]

            Level levelModel ->
                kd [ ( "level", levelView levelModel |> Html.map LevelMsg ) ]

            Summary (Backdrop levelModel) ->
                kd
                    [ ( "summary", summaryView model )
                    , ( "level", levelView levelModel |> Html.map LevelMsg )
                    ]

            Retry (Backdrop levelModel) ->
                kd
                    [ ( "retry", retryView model )
                    , ( "level", levelView levelModel |> Html.map LevelMsg )
                    ]

            Tutorial tutorialModel (Backdrop levelModel) ->
                kd
                    [ ( "tutorial", tutorialView tutorialModel |> Html.map TutorialMsg )
                    , ( "level", levelView levelModel |> Html.map LevelMsg )
                    ]


reset : Html Msg
reset =
    p
        [ onClick ClearCache
        , class "dib top-0 right-1 tracked pointer f7 absolute z-999"
        , style [ color darkYellow ]
        ]
        [ text "reset" ]
