module View exposing (keyedDiv, renderScene, renderSceneState, reset, view)

import Config.Animations exposing (internalAnimations)
import Css.Color exposing (darkYellow)
import Css.Style exposing (color, style)
import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Html.Keyed as K
import Scenes.Hub.View exposing (hubView)
import Scenes.Intro.View exposing (introView)
import Scenes.Level.View exposing (levelView)
import Scenes.Retry exposing (retryView)
import Scenes.Summary exposing (summaryView)
import Scenes.Title exposing (titleView)
import Scenes.Tutorial.View exposing (tutorialView)
import Types exposing (Model, Msg(..), Scene(..), SceneState(..))
import Views.Backdrop exposing (backdrop)
import Views.Loading exposing (loadingScreen)


view : Model -> Html Msg
view model =
    div []
        [ internalAnimations
        , reset
        , loadingScreen model
        , renderSceneState model
        , backdrop
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

        Intro introModel ->
            [ ( "intro", introView introModel |> Html.map IntroMsg ) ]

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
