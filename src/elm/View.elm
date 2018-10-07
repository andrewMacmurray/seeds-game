module View exposing (view)

import Config.Animations exposing (animations)
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
import Types exposing (Model, Msg(..), Scene(..))
import Views.Backdrop exposing (backdrop)
import Views.Loading exposing (loadingScreen)


view : Model -> Html Msg
view model =
    div []
        [ animations
        , reset
        , loadingScreen model
        , keyedDiv <| renderScene model
        , backdrop
        ]


keyedDiv : List ( String, Html msg ) -> Html msg
keyedDiv =
    K.node "div" []


renderScene : Model -> List ( String, Html Msg )
renderScene model =
    case model.scene of
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
