module Views.Menu exposing
    ( Msg
    , Option
    , fadeOut
    , option
    , view
    )

import Css.Animation as Animation exposing (animation)
import Css.Color as Color
import Css.Style as Style exposing (..)
import Css.Transform as Transform exposing (translateX)
import Css.Transition exposing (transition, transitionAll)
import Data.Pointer exposing (onPointerMove, onPointerUp)
import Helpers.Attribute as Attribute
import Html exposing (Attribute, Html, a, button, div, text)
import Html.Attributes exposing (attribute, class, href, target)
import Html.Events exposing (onClick)
import Shared
import Views.Icons.Cog exposing (cog)



-- Message Config


type alias Msg msg =
    { open : msg
    , close : msg
    , resetData : msg
    }



-- Menu Options


type Option msg
    = Option (Config msg)


type alias Config msg =
    { msg : msg
    , text : String
    }


option : msg -> String -> Option msg
option msg text =
    Config msg text |> Option



-- Views


fadeOut : Html msg
fadeOut =
    div
        [ style
            [ opacity 1
            , width 20
            , height 20
            , animation "fade-out" 1000 []
            ]
        , class "absolute top-1 right-1 z-7"
        ]
        [ cog Color.darkYellow ]


view : Msg msg -> Shared.Data -> (sceneMsg -> msg) -> List (Option sceneMsg) -> Html msg
view msg shared sceneMsg sceneSpecificOptions =
    div []
        [ div
            [ class "fixed pointer right-1 top-1 z-7"
            , withDisable shared.menu
            , style [ animation "fade-in" 500 [] ]
            ]
            [ menuDrawerButton msg shared ]
        , div [ class "fixed z-6 top-0", enableWhenOpen shared.menu ]
            [ overlay msg shared
            , drawer msg shared sceneMsg sceneSpecificOptions
            ]
        ]


overlay : Msg msg -> Shared.Data -> Html msg
overlay msg shared =
    let
        visibility =
            case shared.menu of
                Shared.Open ->
                    opacity 0.6

                _ ->
                    opacity 0
    in
    div
        [ style
            [ height <| toFloat shared.window.height
            , width <| toFloat shared.window.width
            , backgroundColor Color.black
            , visibility
            , transitionAll 300 []
            ]
        , enableWhenOpen shared.menu
        , onClick msg.close
        ]
        []


drawer : Msg msg -> Shared.Data -> (sceneMsg -> msg) -> List (Option sceneMsg) -> Html msg
drawer msg shared sceneMsg sceneMenuOptions =
    let
        drawerWidth =
            240

        renderSceneButton =
            renderOption >> Html.map sceneMsg >> onClickCloseMenu msg

        drawerOffset =
            case shared.menu of
                Shared.Open ->
                    transform [ translateX 0 ]

                _ ->
                    transform [ translateX drawerWidth ]

        resetButtonMargin =
            if List.length sceneMenuOptions == 0 then
                0

            else
                75
    in
    div
        [ style
            [ Style.background Color.seedPodGradient
            , height <| toFloat shared.window.height
            , color Color.white
            , width drawerWidth
            , drawerOffset
            , transitionAll 300 []
            ]
        , onPointerUp msg.close
        , attribute "touch-action" "none"
        , class "absolute right-0 top-0 flex flex-column items-center justify-center"
        ]
        (List.concat
            [ List.map renderSceneButton sceneMenuOptions
            , [ div [ style [ marginTop resetButtonMargin ] ] [ menuButtonBorder msg.resetData "Reset Data" ]
              , attributionLink
              ]
            ]
        )


attributionLink : Html msg
attributionLink =
    a
        [ style [ color Color.white ]
        , class "absolute db bottom-1 left-1 f7 ma0 no-underline"
        , href "https://github.com/andrewMacmurray/seeds-game"
        , target "_blank"
        ]
        [ text "A game by Andrew MacMurray" ]


withDisable : Shared.Menu -> Attribute msg
withDisable menu =
    case menu of
        Shared.Disabled ->
            class "touch-disabled"

        _ ->
            Attribute.empty


onClickCloseMenu : Msg msg -> Html msg -> Html msg
onClickCloseMenu msg button =
    div [ onClick msg.close ] [ button ]


renderOption : Option msg -> Html msg
renderOption (Option { msg, text }) =
    menuButtonSolid msg Color.white Color.lightGold text


enableWhenOpen : Shared.Menu -> Attribute msg
enableWhenOpen menu =
    case menu of
        Shared.Open ->
            Attribute.empty

        _ ->
            class "touch-disabled"


menuButtonSolid : msg -> Color.Color -> Color.Color -> String -> Html msg
menuButtonSolid msg textColor bgColor content =
    button
        [ style
            [ borderNone
            , backgroundColor bgColor
            , width 150
            , color textColor
            ]
        , class "outline-0 br4 f6 pv2 ph3 mv2 ttu pointer sans-serif tracked-mega"
        , onClick msg
        ]
        [ text content ]


menuButtonBorder : msg -> String -> Html msg
menuButtonBorder msg content =
    button
        [ style
            [ border 2 Color.white
            , width 150
            , backgroundColor Color.transparent
            , color Color.white
            ]
        , class "outline-0 br4 pv2 ph3 mv2 ttu pointer sans-serif tracked-mega"
        , onClick msg
        ]
        [ text content ]


menuDrawerButton : Msg msg -> Shared.Data -> Html msg
menuDrawerButton { open, close } shared =
    case shared.menu of
        Shared.Open ->
            div
                [ onClick close
                , style
                    [ transform [ Transform.rotateZ 0 ]
                    , width 20
                    , height 20
                    , transitionAll 300 []
                    ]
                ]
                [ cog Color.white ]

        _ ->
            div
                [ onClick open
                , style
                    [ transform [ Transform.rotateZ 180 ]
                    , width 20
                    , height 20
                    , transitionAll 300 []
                    ]
                ]
                [ cog Color.darkYellow ]
