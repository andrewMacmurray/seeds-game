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
import Types exposing (Model, Msg(..), Scene(..), SceneState(..))
import Views.Backdrop exposing (backdrop)
import Views.Loading exposing (loadingScreen)


view : Model -> Html Msg
view model =
    div []
        [ embeddedAnimations model.xAnimations
        , reset
        , loadingScreen model
        , renderSceneState model
        , backdrop
        ]


embeddedAnimations : String -> Html msg
embeddedAnimations externalanimations =
    div []
        [ embeddedStyle externalanimations
        , internalAnimations
        ]


renderSceneState : Model -> Html Msg
renderSceneState model =
    case model.scene of
        Loaded scene ->
            keyedDiv <| renderScene model scene

        Transition { from, to } ->
            keyedDiv <|
                List.concat
                    [ renderScene model to
                    , renderScene model from
                    ]


keyedDiv : List ( String, Html msg ) -> Html msg
keyedDiv =
    K.node "div" []


renderScene : Model -> Scene -> List ( String, Html Msg )
renderScene model scene =
    case scene of
        Hub ->
            [ ( "hub", hubView model ) ]

        Title ->
            [ ( "title", titleView model ) ]

        Level levelModel ->
            [ ( "level", levelView levelModel |> Html.map LevelMsg ) ]

        Summary ->
            [ ( "summary", summaryView model ) ]

        Retry ->
            [ ( "retry", retryView model ) ]

        Tutorial tutorialModel ->
            [ ( "tutorial", tutorialView tutorialModel |> Html.map TutorialMsg )
            , ( "level", levelView tutorialModel.levelModel |> Html.map LevelMsg )
            ]


reset : Html Msg
reset =
    p
        [ onClick ClearCache
        , class "dib top-0 right-1 tracked pointer f7 absolute z-999"
        , style [ color darkYellow ]
        ]
        [ text "reset" ]
