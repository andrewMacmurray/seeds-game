module Views.Menu exposing (Msg, view)

import Css.Color as Color
import Css.Style as Style exposing (..)
import Css.Transform as Transform exposing (translateX)
import Css.Transition exposing (transitionAll)
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


view : Msg msg -> Shared.Data -> Html msg
view msg shared =
    div [ class "absolute top-0 right-0 w-100" ]
        [ menuDrawerButton msg shared
        , div [ class "absolute z-6", enableWhenOpen shared.menuOpen ]
            [ div
                [ style
                    [ height <| toFloat shared.window.height
                    , width <| toFloat shared.window.width
                    , backgroundColor Color.black
                    , overlayVisibility shared.menuOpen
                    , transitionAll 300 []
                    ]
                , enableWhenOpen shared.menuOpen
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
                    , menuDrawerPosition shared.menuOpen
                    , transitionAll 300 []
                    ]
                , class "absolute right-0 top-0 flex flex-column items-center justify-center"
                ]
                [ menuButton msg.close Color.lightGold "Go To Levels"
                , menuButton msg.resetData Color.lightOrange "Reset Data"
                ]
            ]
        ]


overlayVisibility menuOpen =
    if menuOpen then
        opacity 0.6

    else
        opacity 0


enableWhenOpen menuOpen =
    if menuOpen then
        Attribute.empty

    else
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


menuDrawerButton { open, close } shared =
    let
        classes =
            "absolute pointer right-1 top-1 z-7"
    in
    if shared.menuOpen then
        div
            [ onClick close
            , class classes
            , style
                [ transform [ Transform.rotateZ 0 ]
                , width 20
                , height 20
                , transitionAll 300 []
                ]
            ]
            [ cog Color.white ]

    else
        div
            [ onClick open
            , class classes
            , style
                [ transform [ Transform.rotateZ 180 ]
                , width 20
                , height 20
                , transitionAll 300 []
                ]
            ]
            [ cog Color.darkYellow ]


menuDrawerPosition menuOpen =
    if menuOpen then
        transform [ translateX 0 ]

    else
        transform [ translateX 270 ]
