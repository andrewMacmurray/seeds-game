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
import Helpers.Attribute as Attribute
import Html exposing (Html, button, div, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Shared
import Views.Icons.Cog exposing (cog)


type alias Msg msg =
    { open : msg
    , close : msg
    , resetData : msg
    }


type alias OptionConfig msg =
    { msg : msg
    , text : String
    , backgroundColor : Color.Color
    }


type Option msg
    = Option (OptionConfig msg)


option : msg -> String -> Color.Color -> Option msg
option msg text color =
    OptionConfig msg text color |> Option


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
            [ div
                [ style
                    [ height <| toFloat shared.window.height
                    , width <| toFloat shared.window.width
                    , backgroundColor Color.black
                    , overlayVisibility shared.menu
                    , transitionAll 300 []
                    ]
                , enableWhenOpen shared.menu
                , onClick msg.close
                ]
                []
            , div
                [ style
                    [ Style.background Color.seedPodGradient
                    , height <| toFloat shared.window.height
                    , color Color.white
                    , width 270
                    , borderRadiusBottomLeft 20
                    , borderRadiusTopLeft 20
                    , menuDrawerPosition shared.menu
                    , transitionAll 300 []
                    ]
                , class "absolute right-0 top-0 flex flex-column items-center justify-center"
                ]
              <|
                List.concat
                    [ List.map (renderOption >> Html.map sceneMsg >> closeMenu msg) sceneSpecificOptions
                    , [ menuButton msg.resetData Color.lightOrange "Reset Data" ]
                    ]
            ]
        ]


withDisable menu =
    case menu of
        Shared.Disabled ->
            class "touch-disabled"

        _ ->
            Attribute.empty


closeMenu msg button =
    div [ onClick msg.close ] [ button ]


renderOption (Option config) =
    menuButton config.msg config.backgroundColor config.text


overlayVisibility menu =
    case menu of
        Shared.Open ->
            opacity 0.6

        _ ->
            opacity 0


enableWhenOpen menu =
    case menu of
        Shared.Open ->
            Attribute.empty

        _ ->
            class "touch-disabled"


menuButton msg bgColor content =
    button
        [ style
            [ borderNone
            , backgroundColor bgColor
            , width 150
            , color Color.white
            ]
        , class "outline-0 br4 pv2 ph3 mv2 f6 ttu pointer sans-serif tracked"
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


menuDrawerPosition menu =
    case menu of
        Shared.Open ->
            transform [ translateX 0 ]

        _ ->
            transform [ translateX 270 ]
