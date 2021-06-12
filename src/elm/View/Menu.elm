module View.Menu exposing
    ( Msg
    , Option
    , fadeOut
    , option
    , view
    )

import Context exposing (Context)
import Css.Animation exposing (animation)
import Css.Color as Color
import Css.Style as Style exposing (..)
import Css.Transform as Transform exposing (translateX)
import Css.Transition exposing (transitionAll)
import Html exposing (Attribute, Html, a, button, div, text)
import Html.Attributes exposing (attribute, class, href, target)
import Html.Events exposing (onClick)
import Pointer exposing (onPointerUp)
import Utils.Attribute as Attribute
import View.Icon.Cog as Icon



-- Message Config


type alias Msg msg =
    { open : msg
    , close : msg
    , resetData : msg
    }



-- Menu Option


type Option msg
    = Option (Config msg)


type alias Config msg =
    { msg : msg
    , text : String
    }


option : msg -> String -> Option msg
option msg text =
    Option (Config msg text)



-- View


fadeOut : Html msg
fadeOut =
    div
        [ style
            [ opacity 1
            , width 20
            , height 20
            , animation "fade-out" 1000 []
            ]
        , class "absolute top-1 right-1 z-9"
        ]
        [ Icon.cog Color.darkYellow ]


view : Msg msg -> Context -> (sceneMsg -> msg) -> List (Option sceneMsg) -> Html msg
view msg context sceneMsg sceneSpecificOptions =
    div []
        [ div
            [ class "fixed pointer right-1 top-1 z-9"
            , withDisable context.menu
            , style [ animation "fade-in" 500 [] ]
            ]
            [ menuDrawerButton msg context ]
        , div [ class "fixed z-8 top-0", enableWhenOpen context.menu ]
            [ overlay msg context
            , drawer msg context sceneMsg sceneSpecificOptions
            ]
        ]


overlay : Msg msg -> Context -> Html msg
overlay msg context =
    let
        visibility =
            case context.menu of
                Context.Open ->
                    opacity 0.6

                _ ->
                    opacity 0
    in
    div
        [ style
            [ height <| toFloat context.window.height
            , width <| toFloat context.window.width
            , backgroundColor Color.black
            , visibility
            , transitionAll 300 []
            ]
        , enableWhenOpen context.menu
        , onClick msg.close
        ]
        []


drawer : Msg msg -> Context -> (sceneMsg -> msg) -> List (Option sceneMsg) -> Html msg
drawer msg context sceneMsg sceneMenuOptions =
    let
        drawerWidth =
            240

        renderSceneButton =
            renderOption >> Html.map sceneMsg

        drawerOffset =
            case context.menu of
                Context.Open ->
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
            , height <| toFloat context.window.height
            , color Color.white
            , width drawerWidth
            , drawerOffset
            , transitionAll 300 []
            ]
        , attribute "touch-action" "none"
        , class "absolute right-0 top-0 flex flex-column items-center justify-center"
        ]
        (List.concat
            [ List.map renderSceneButton sceneMenuOptions
            , [ div [ style [ marginTop resetButtonMargin ] ] [ menuButtonBorder msg.resetData "Reset Data" ]
              , attributionLink
              , closeMenuCaptureArea msg
              ]
            ]
        )


closeMenuCaptureArea : Msg msg -> Html msg
closeMenuCaptureArea msg =
    div [ class "w-100 h-100 z-6 absolute top-0 left-0", onPointerUp msg.close ] []


attributionLink : Html msg
attributionLink =
    a
        [ style [ color Color.white ]
        , class "absolute db bottom-1 z-9 left-1 f7 ma0 no-underline"
        , href "https://github.com/andrewMacmurray/seeds-game"
        , target "_blank"
        ]
        [ text "A game by Andrew MacMurray" ]


withDisable : Context.Menu -> Attribute msg
withDisable menu =
    case menu of
        Context.Disabled ->
            class "touch-disabled"

        _ ->
            Attribute.empty


renderOption : Option msg -> Html msg
renderOption (Option { msg, text }) =
    menuButtonSolid msg Color.white Color.lightGold text


enableWhenOpen : Context.Menu -> Attribute msg
enableWhenOpen menu =
    case menu of
        Context.Open ->
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
        , class "outline-0 relative z-9 br4 f6 pv2 ph3 mv2 ttu pointer sans-serif tracked-mega"
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
        , class "outline-0 relative z-9 br4 pv2 ph3 mv2 ttu pointer sans-serif tracked-mega"
        , onClick msg
        ]
        [ text content ]


menuDrawerButton : Msg msg -> Context -> Html msg
menuDrawerButton { open, close } context =
    case context.menu of
        Context.Open ->
            div
                [ onClick close
                , style
                    [ transform [ Transform.rotate 0 ]
                    , width 20
                    , height 20
                    , transitionAll 300 []
                    ]
                ]
                [ Icon.cog Color.white ]

        _ ->
            div
                [ onClick open
                , style
                    [ transform [ Transform.rotate 180 ]
                    , width 20
                    , height 20
                    , transitionAll 300 []
                    ]
                ]
                [ Icon.cog Color.darkYellow ]
